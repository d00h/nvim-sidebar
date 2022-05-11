import io
import json
import re
import subprocess
import sys
from argparse import ArgumentParser
from typing import Iterable

XREF_REGEX = re.compile(r'(\w+)\s+(\w+)\s+(\d+)\s([^\s]+)\s(.+)')


def parse_line(line: str):
    match = XREF_REGEX.match(line)
    if match:
        print(match.group(5))


def create_parser() -> ArgumentParser:
    parser = ArgumentParser()
    parser.add_argument('filename')
    return parser


def process(args):
    proc = subprocess.Popen(
        ['ctags', '-o-', '--sort=no', '--output-format=json', args.filename],
        stdout=subprocess.PIPE
    )
    for line in io.TextIOWrapper(proc.stdout, encoding="utf-8"):
        data = json.loads(line)
        pattern = data.get('pattern')
        pattern = pattern.replace('/^', '')
        pattern = pattern.replace('$/', '')
        print(pattern)


def main():
    parser = create_parser()
    if len(sys.argv) == 1:
        parser.print_help()
        return
    args = parser.parse_args()
    process(args)


if __name__ == '__main__':
    main()
