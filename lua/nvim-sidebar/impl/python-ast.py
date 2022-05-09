import ast
import os
import re
import sys
from argparse import ArgumentParser
from argparse import Namespace as ArgumentNamespace
from dataclasses import dataclass
from typing import Iterable


def find_python_sources(path: str) -> Iterable[str]:
    if os.path.isfile(path):
        yield path
    else:
        for root, _, files in os.walk(path):
            for file in files:
                if not file.endswith(".py"):
                    continue
                yield os.path.join(root, file)


def parse_python_source(filename) -> Iterable[ast.AST]:
    with open(filename, 'rt') as stream:
        source = stream.read()
        parsed = ast.parse(source, filename)
        yield from ast.walk(parsed)


def get_ast_name(node: ast.AST):

    if isinstance(node, ast.FunctionDef):
        function_def: ast.FunctionDef = node
        return get_ast_name(function_def.name)

    if isinstance(node, ast.Name):
        name: ast.Name = node
        return name.id

    if isinstance(node, ast.Call):
        call: ast.Call = node
        return get_ast_name(call.func)

    if isinstance(node, ast.Attribute):
        attribute: ast.Attribute = node
        return get_ast_name(attribute.attr)

    if isinstance(node, str):
        return node

    raise ValueError(type(node))


@dataclass
class PythonFunction:

    filename: str
    line: int
    name: str

    @classmethod
    def find(cls, filename) -> Iterable['PythonDecorator']:
        for node in parse_python_source(filename):
            if isinstance(node, ast.FunctionDef):
                for decorator in node.decorator_list:
                    yield cls(
                        filename=filename,
                        line=node.lineno,
                        name=get_ast_name(node)
                    )


@dataclass
class PythonDecorator:

    filename: str
    line: int
    name: str
    decorator: str

    @classmethod
    def find(cls, filename) -> Iterable['PythonDecorator']:
        for node in parse_python_source(filename):
            if isinstance(node, ast.FunctionDef):
                for decorator in node.decorator_list:
                    yield cls(
                        filename=filename,
                        line=node.lineno,
                        name=get_ast_name(node),
                        decorator=get_ast_name(decorator),
                    )


def create_parser() -> ArgumentParser:
    parser = ArgumentParser()

    subparsers = parser.add_subparsers()
    find_decorators_parser = subparsers.add_parser('find-decorators')
    find_decorators_parser.add_argument('decorator_pattern', help='regexp')
    find_decorators_parser.add_argument('path', nargs='?') 
    find_decorators_parser.set_defaults(command=command_find_decorators)

    find_functions_parser = subparsers.add_parser('find-functions')
    find_functions_parser.add_argument('function_pattern', help='regexp')
    find_functions_parser.add_argument('path', nargs='?')
    find_functions_parser.set_defaults(command=command_find_functions)

    return parser


def command_find_functions(args: ArgumentNamespace):
    pattern = re.compile(args.function_pattern)
    path = args.path or os.getcwd()
    prev_filename = None

    for filename in find_python_sources(path):
        for target in PythonFunction.find(filename):
            if not pattern.match(target.name):
                continue

            if prev_filename != filename:
                print(f'\n{filename}')
                prev_filename = filename

            print(f'{target.line}: {target.name}')


def command_find_decorators(args: ArgumentNamespace):
    pattern = re.compile(args.decorator_pattern)
    path = args.path or os.getcwd()
    prev_filename = None

    for filename in find_python_sources(path):
        for target in PythonDecorator.find(filename):
            if not pattern.match(target.decorator):
                continue

            if prev_filename != filename:
                print(f'\n{filename}')
                prev_filename = filename

            print(f'{target.line}: {target.name}')


def main():
    parser = create_parser()
    if len(sys.argv) == 1:
        parser.print_help()
        return
    args = parser.parse_args()

    try:
        args.command(args)
    except BaseException as ex:
        print('error:', ex)
        raise


if __name__ == '__main__':
    main()
