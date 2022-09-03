from colorama import Fore, Style


def printError(msg):
    print(Fore.RED + msg)
    print(Style.RESET_ALL)

def printSuccess(msg):
    print(Fore.GREEN + msg)
    print(Style.RESET_ALL)
