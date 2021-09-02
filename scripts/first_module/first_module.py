"""This module demonstrates how to construct python project.

- Author: Jongkuk Lim
- Contact: limjk@jmarple.ai
"""


def demo_print_hello(n_repeat: int) -> None:
    """Print 'Hello' n_repeat times.

    Args:
        n_repeat: Number of repeatition.

    Returns:
        None. Describe return values if a function has the return values
    """
    for _ in range(n_repeat):
        print("Hello")
