from colorama import Fore, Style


def printg(msg):
    print(Fore.GREEN + str(msg))
    print(Style.RESET_ALL)


def printy(msg):
    print(Fore.YELLOW + str(msg))
    print(Style.RESET_ALL)


def printr(msg):
    print(Fore.RED + str(msg))
    print(Style.RESET_ALL)
