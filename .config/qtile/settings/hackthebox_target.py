#!/usr/bin/env python3

import subprocess

import os

#Intenta abrir y leer el archivo

def read_target_info(file_path):
    
    try:
    
        with open(file_path, 'r') as file:

            lines = file.read().splitlines()
        
            if lines and len(lines[0].split()) >= 2:

                return tuple(map(str.strip, lines[0].split()[:2]))
            
            else:
            
                print("0.0.0.0 - undefined 󰍸 ") # nf-md-minus_network
            
    except FileNotFoundError:
    
        print("Error: Target file not found!")
    
    except Exception as e:

        print(f"Error reading target information: {e}")

    return None, None

#Ejecuta el ping y verifica el estado

def check_status(ip_address):

    try:
    
        result = subprocess.run(['ping', '-c', '1', '-W', '1', ip_address], capture_output = True, text = True, check = True)

        return result.returncode == 0 and '1 packets transmitted' in result.stdout

    except Exception as e:

        return False
    
def main():

    file_path = os.path.join(os.getenv("HOME"), '.config/qtile/htbtarget')

    ip_address, machine_name = read_target_info(file_path)

    if ip_address is not None:

        #nf-md-check_network
        status_indicator = "󰱓 " if check_status(ip_address) else "󰅛 " # nf-md-close_network
   
        print(f"{ip_address} - {machine_name} {status_indicator}")

if __name__ == "__main__":

    main()
