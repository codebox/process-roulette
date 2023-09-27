#!/usr/bin/env python3

import os
import random
import shutil
import time

SCORE = 0
ROUND = 1
ME = os.getlogin()
COLS, _ = shutil.get_terminal_size()
BAR = '=' * COLS
NUMERIC = '^[0-9]+$'
STOP_NOW = 'i am a coward'
ROOT_USER = 'root'

def center_text(TEXT=''):
    PRE_SPACES = (COLS - len(TEXT) - 2) // 2
    POST_SPACES = COLS - 2 - len(TEXT) - PRE_SPACES
    print('#', end='')
    print(' ' * PRE_SPACES, end='')
    print(TEXT, end='')
    print(' ' * POST_SPACES, end='')
    print('#')

def intro():
    os.system('clear')
    print(BAR)
    center_text()
    center_text("--==[ PROCESS ROULETTE ]==--")
    center_text()
    center_text("This game randomly kills processes running on your computer")
    center_text("Other users' processes are worth more points")
    center_text(f"To get the highest scores play as the '{ROOT_USER}' user")
    center_text("If the game kills itself, or crashes your computer, you score nothing")
    center_text()
    center_text("!!! Playing this game may crash or destabilise your computer !!!")
    center_text("When you finish playing you should probably reboot")
    center_text()
    if ME == ROOT_USER:
        center_text(f"!!! You are playing as {ROOT_USER} !!!")
        center_text()
    center_text("Enter the number of rounds you wish to play")
    center_text(f"To stop now enter '{STOP_NOW}'")
    center_text()
    print(BAR)

    while True:
        ANSWER = input("How many rounds? > ")
        if ANSWER == STOP_NOW:
            print("Game aborted, that's probably for the best.")
            exit(1)
        elif ANSWER.isdigit():
            ROUNDS = int(ANSWER)
            print(f"Playing {ROUNDS} rounds...")
            break

def select_random():
    process_info = os.popen("ps -eo pid,user,comm").read().strip().split('\n')[1:]
    random_process = random.choice(process_info)
    PID, USR, CMD = random_process.split()
    CMD = CMD.split('/')[-1]
    POINTS = 0

    if USR == ROOT_USER:
        POINTS = 5
    elif USR == ME:
        POINTS = 1
    else:
        POINTS = 2

    return PID, USR, CMD, POINTS

def print_details(PREFIX='', SUFFIX=''):
    CLEAR_LINE = "\r\033[K"
    print(f"{CLEAR_LINE} {PREFIX} {PID} {CMD} {SUFFIX}", end='', flush=True)

def spin():
    SLEEP = 0.02
    COUNT = 0
    MAX_COUNT = 12
    FRICTION = 1.3000
    ARROW_RIGHT = "==> "
    ARROW_LEFT = " <=="

    while True:
        PID, USR, CMD, POINTS = select_random()
        print_details()
        time.sleep(SLEEP)
        SLEEP *= FRICTION
        COUNT += 1
        if COUNT > MAX_COUNT:
            break

    print_details(ARROW_RIGHT, ARROW_LEFT)
    time.sleep(0.5)
    print_details()
    time.sleep(0.5)
    print_details(ARROW_RIGHT, ARROW_LEFT)

    try:
        os.kill(int(PID), 9)
        global SCORE
        SCORE += POINTS
        print(f" KILLED for {POINTS} point{'s' if POINTS > 1 else ''} [{USR}]")
    except Exception as e:
        print(f" FAILED 0 points{' (try running as {ROOT_USER})' if ME != ROOT_USER else ''}")

    time.sleep(1)
    print()

intro()

while ROUND <= ROUNDS:
    spin()
    ROUND += 1

print(f"You survived {ROUNDS} round/s and scored {SCORE} points")
