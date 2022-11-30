from colorama import Fore, Style


def printg(msg):
    print(Fore.GREEN + msg)
    print(Style.RESET_ALL)


def printy(msg):
    print(Fore.YELLOW + msg)
    print(Style.RESET_ALL)


def printr(msg):
    print(Fore.RED + msg)
    print(Style.RESET_ALL)
