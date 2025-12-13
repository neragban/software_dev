#This is a multi-threaded port scanner that 
#scans network devices for open ports and attempts 
# to identify device types. It uses concurrent threading 
# to efficiently scan multiple ports simultaneously and 
# provides both basic port scanning and HTTP service checking capabilities. 


import socket
import threading
import time
import requests

# Colored printing
RED = "\033[91m"
GREEN = "\033[92m"
YELLOW = "\033[93m"
RESET = "\033[0m"

# Common ports and their services
COMMON_PORTS = {
    22: "SSH",
    23: "Telnet",
    53: "DNS",
    80: "HTTP",
    139: "NetBIOS",
    443: "HTTPS",
    445: "SMB",
    3389: "RDP",
    135: "RPC",
}

open_ports = []

def log(text):
    with open("scan_results.txt", "a") as f:
        f.write(text + "\n")

def scan_port(ip, port):
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.settimeout(0.3)
    try:
        s.connect((ip, port))
        open_ports.append(port)
    except:
        pass
    s.close()

def guess_device(ports):
    if 445 in ports or 139 in ports or 135 in ports:
        return "Windows device"
    if 22 in ports:
        return "Linux / Unix / Raspberry Pi"
    return "Unknown device"

def start_scan(ip):
    open_ports.clear()
    threads = []

    for port in COMMON_PORTS:
        t = threading.Thread(target=scan_port, args=(ip, port))
        threads.append(t)
        t.start()

    for t in threads:
        t.join()

    if open_ports:
        print(f"\n{GREEN}Open ports found on {ip}:{RESET}")
        log(f"Open ports for {ip}:")
        for p in open_ports:
            service = COMMON_PORTS.get(p, "Unknown")
            print(f"{YELLOW}- Port {p}: {service}{RESET}")
            log(f"Port {p}: {service}")

        device = guess_device(open_ports)
        print(f"\n{GREEN}Device type guess: {device}{RESET}")
        log(f"Device type guess: {device}")
    else:
        print(f"{RED}\nNo common ports open on {ip}.{RESET}")
        log(f"No ports open for {ip}")

def check_http_service(url):
    print(f"{YELLOW}Checking HTTP service: {url}{RESET}")
    log(f"Checking URL: {url}")

    try:
        start = time.time()
        response = requests.get(url, timeout=3)
        end = time.time()

        ms = round((end - start) * 1000, 2)

        print(f"{GREEN}Status: {response.status_code} ({response.reason}){RESET}")
        print(f"{GREEN}Response Time: {ms} ms{RESET}")

        log(f"HTTP {url} -> {response.status_code}, {response.reason}, {ms} ms")

    except Exception as e:
        print(f"{RED}Error: {e}{RESET}")
        log(f"HTTP {url} -> ERROR: {e}")

if __name__ == "__main__":
    print("1) Port Scan")
    print("2) HTTP Service Check")
    choice = input("Choose option: ")

    if choice == "1":
        ip = input("Enter IP to scan: ")
        print(f"{YELLOW}Scanning {ip}...\n{RESET}")
        start_scan(ip)

    elif choice == "2":
        url = input("Enter URL (example: http://example.com): ")
        if not url.startswith("http"):
            url = "http://" + url
        check_http_service(url)

    print(f"{GREEN}\nResults saved to scan_results.txt{RESET}")
