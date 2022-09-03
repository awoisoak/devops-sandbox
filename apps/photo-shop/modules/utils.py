from colorama import Fore, Style

# Print the passed message in green
def printSuccess(msg):
    print(Fore.GREEN + msg)
    print(Style.RESET_ALL)

# Print the passed message in yellow
def printWarning(msg):
    print(Fore.YELLOW + msg)
    print(Style.RESET_ALL)

# Print the passed message in red
def printError(msg):
    print(Fore.RED + msg)
    print(Style.RESET_ALL)

# Filter unwanted files names
def filterImages(image_names):
    filter='.DS_Store'
    if (filter in image_names):
        image_names.remove(filter)
    print(image_names)
    return image_names    