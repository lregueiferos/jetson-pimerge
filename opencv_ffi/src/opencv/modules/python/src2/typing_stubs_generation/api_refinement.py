__all__ = [
    "apply_manual_api_refinement"
]

from typing import cast, Sequence, Callable, Iterable

from .nodes import (NamespaceNode, FunctionNode, OptionalTypeNode, TypeNode,
                    ClassProperty, PrimitiveTypeNode, ASTNodeTypeNode,
                    AggregatedTypeNode)
from .ast_utils import (find_function_node, SymbolName,
                        for_each_function_overload)


def apply_manual_api_refinement(root: NamespaceNode) -> None:
    refine_cuda_module(root)
    export_matrix_type_constants(root)
    # Export OpenCV exception class
    builtin_exception = root.add_class("Exception")
    builtin_exception.is_exported = False
    root.add_class("error", (builtin_exception, ), ERROR_CLASS_PROPERTIES)
    for symbol_name, refine_symbol in NODES_TO_REFINE.items():
        refine_symbol(root, symbol_name)


def export_matrix_type_constants(root: NamespaceNode) -> None:
    MAX_PREDEFINED_CHANNELS = 4

    depth_names = ("CV_8U", "CV_8S", "CV_16U", "CV_16S", "CV_32S",
                   "CV_32F", "CV_64F", "CV_16F")
    for depth_value, depth_name in enumerate(depth_names):
        # Export depth constants
        root.add_constant(depth_name, str(depth_value))
        # Export predefined types
        for c in range(MAX_PREDEFINED_CHANNELS):
            root.add_constant(f"{depth_name}C{c + 1}",
                              f"{depth_value + 8 * c}")
        # Export type creation function
        root.add_function(
            f"{depth_name}C",
            (FunctionNode.Arg("channels", PrimitiveTypeNode.int_()), ),
            FunctionNode.RetType(PrimitiveTypeNode.int_())
        )
    # Export CV_MAKETYPE
    root.add_function(
        "CV_MAKETYPE",
        (FunctionNode.Arg("depth", PrimitiveTypeNode.int_()),
         FunctionNode.Arg("channels", PrimitiveTypeNode.int_())),
        FunctionNode.RetType(PrimitiveTypeNode.int_())
    )


def make_optional_arg(arg_name: str) -> Callable[[NamespaceNode, SymbolName], None]:
    def _make_optional_arg(root_node: NamespaceNode,
                           function_symbol_name: SymbolName) -> None:
        function = find_function_node(root_node, function_symbol_name)
        for overload in function.overloads:
            arg_idx = _find_argument_index(overload.arguments, arg_name)
            # Avoid multiplying optional qualification
            if isinstance(overload.arguments[arg_idx].type_node, OptionalTypeNode):
                continue

            overload.arguments[arg_idx].type_node = OptionalTypeNode(
                cast(TypeNode, overload.arguments[arg_idx].type_node)
            )

    return _make_optional_arg


def refine_cuda_module(root: NamespaceNode) -> None:
    def fix_cudaoptflow_enums_names() -> None:
        for class_name in ("NvidiaOpticalFlow_1_0", "NvidiaOpticalFlow_2_0"):
            if class_name not in cuda_root.classes:
                continue
            opt_flow_class = cuda_root.classes[class_name]
            _trim_class_name_from_argument_types(
                for_each_function_overload(opt_flow_class), class_name
            )

    def fix_namespace_usage_scope(cuda_ns: NamespaceNode) -> None:
        USED_TYPES = ("GpuMat", "Stream")

        def fix_type_usage(type_node: TypeNode) -> None:
            if isinstance(type_node, AggregatedTypeNode):
                for item in type_node.items:
                    fix_type_usage(item)
            if isinstance(type_node, ASTNodeTypeNode):
                if type_node._typename in USED_TYPES:
                    type_node._typename = f"cuda_{type_node._typename}"

        for overload in for_each_function_overload(cuda_ns):
            if overload.return_type is not None:
                fix_type_usage(overload.return_type.type_node)
            for type_node in [arg.type_node for arg in overload.arguments
                              if arg.type_node is not None]:
                fix_type_usage(type_node)

    if "cuda" not in root.namespaces:
        return
    cuda_root = root.namespaces["cuda"]
    fix_cudaoptflow_enums_names()
    for ns in [ns for ns_name, ns in root.namespaces.items()
               if ns_name.startswith("cuda")]:
        fix_namespace_usage_scope(ns)


def _trim_class_name_from_argument_types(
    overloads: Iterable[FunctionNode.Overload],
    class_name: str
) -> None:
    separator = f"{class_name}_"
    for overload in overloads:
        for arg in [arg for arg in overload.arguments
                    if arg.type_node is not None]:
            ast_node = cast(ASTNodeTypeNode, arg.type_node)
            if class_name in ast_node.ctype_name:
                fixed_name = ast_node._typename.split(separator)[-1]
                ast_node._typename = fixed_name


def _find_argument_index(arguments: Sequence[FunctionNode.Arg],
                         name: str) -> int:
    for i, arg in enumerate(arguments):
        if arg.name == name:
            return i
    raise RuntimeError(
        f"Failed to find argument with name: '{name}' in {arguments}"
    )


NODES_TO_REFINE = {
    SymbolName(("cv", ), (), "resize"): make_optional_arg("dsize"),
    SymbolName(("cv", ), (), "calcHist"): make_optional_arg("mask"),
}

ERROR_CLASS_PROPERTIES = (
    ClassProperty("code", PrimitiveTypeNode.int_(), False),
    ClassProperty("err", PrimitiveTypeNode.str_(), False),
    ClassProperty("file", PrimitiveTypeNode.str_(), False),
    ClassProperty("func", PrimitiveTypeNode.str_(), False),
    ClassProperty("line", PrimitiveTypeNode.int_(), False),
    ClassProperty("msg", PrimitiveTypeNode.str_(), False),
)
