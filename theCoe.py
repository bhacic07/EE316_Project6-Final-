import numpy as np
import os



def main():
    print(f"cwd: {os.getcwd()}")
    os.chdir(r"C:\Temp\EE316\p6\EE316_Project6-Final")
    print(f"cwd: {os.getcwd()}")
    file = open('coeFile3.coe','w')
    t = np.linspace(0,1,38400) #38400 data points bw 0 and 1
    x = np.sin(2*np.pi*t)
    f = 0.5*x + 0.5
    f*= 40
    
    file.write(str("memory_initialization_radix=16; \n"))
    file.write(str("memory_initialization_vector= \n"))
    
    for i in range(0,len(f)):
        file.write(str(hex(int(f[i]))) + ",\n")
        
    
if __name__ == "__main__":
    main()
