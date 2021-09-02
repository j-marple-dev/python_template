"""Main script for your project.

- Author: Jongkuk Lim
- Contact: limjk@jmarple.ai
"""


import argparse

from scripts.first_module.first_module import demo_print_hello
from scripts.second_module.second_module import demo_generate_world


def get_parser() -> argparse.Namespace:
    """Get argument parser.

    Modify this function as your porject needs
    """
    parser = argparse.ArgumentParser(
        formatter_class=argparse.ArgumentDefaultsHelpFormatter
    )
    parser.add_argument("--hello", type=int, default=2, help="Print 'hello' n times")
    parser.add_argument("--world", type=int, default=3, help="Print 'world' n times")

    return parser.parse_args()


if __name__ == "__main__":
    args = get_parser()

    demo_print_hello(args.hello)
    world_repeated = demo_generate_world(args.world)
    print(world_repeated)
