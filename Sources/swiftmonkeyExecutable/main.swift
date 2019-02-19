import Foundation
import swiftmonkey

let logo = """

▒█▀▄▀█ ▒█▀▀▀█ ▒█▄░▒█ ▒█░▄▀ ▒█▀▀▀ ▒█░░▒█
▒█▒█▒█ ▒█░░▒█ ▒█▒█▒█ ▒█▀▄░ ▒█▀▀▀ ▒█▄▄▄█
▒█░░▒█ ▒█▄▄▄█ ▒█░░▀█ ▒█░▒█ ▒█▄▄▄ ░░▒█░░

"""

let userName = NSUserName()
print(logo)
print("Hello \(userName)! This is the Monkey programming language")
print("Feel free to type in commands\n")
startRepl()

