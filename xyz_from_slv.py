# This script writes a dummy xyz file to be read in VMD
# Use: python xyz_from_slv.py  myslv.slv
#
# The input is a .slv file generated from Platon's SolvF3D function
#
# For VMD, try using QuickSurf representation:
# mol new myout.xyz
# mol modstyle 0 0 QuickSurf  0.1  1.5  0.5  3.0


import numpy as np
import shutil
import sys
import tempfile

infile = sys.argv[1]

def slv2xyz(infile):
    with open(infile, 'r') as fin:
        with open('myout.xyz', 'w') as fout:

            a = None
            b = None
            c = None
            Nx = None
            Ny = None
            Nz = None
            j = 0
            ones = 0

            for line in fin:

                # Get grid specs
                if line[0:4]=='CELL':
                    _, a, b, c, alpha, beta, gamma = line.split()
                    a,b,c = map(float, [a,b,c])

                if line[0:4]=='SIZE':
                    _, Nx, Ny, Nz = line.split()
                    Nx,Ny,Nz = map(int, [Nx,Ny,Nz])

                    xarr_edges = np.linspace(0, a, Nx+1)
                    yarr_edges = np.linspace(0, b, Ny+1)
                    zarr_edges = np.linspace(0, c, Nz+1)

                    xarr = 0.5 * (xarr_edges[1:] + xarr_edges[:-1])
                    yarr = 0.5 * (yarr_edges[1:] + yarr_edges[:-1])
                    zarr = 0.5 * (zarr_edges[1:] + zarr_edges[:-1])

                # Split line into characters
                chars = list(line.rstrip())

                # Process line if it contains void data
                if len(chars)==Nx:
                    for i, char in enumerate(chars):
                        if char=='1':
                            fout.write('{} {} {} {}\n'.format('C', xarr[i], yarr[j%Ny], zarr[j//Ny]))
                            ones +=1
                    j+=1
    return ones


def prepend(string, infile):
    with open(infile, 'r') as fin:

        tmpfile = tempfile.NamedTemporaryFile(delete=False)
        with open(tmpfile.name, 'w') as fout:

            fout.write('{}\n\n'.format(string))

            for line in fin:
                fout.write(line)

    shutil.move(tmpfile.name, infile)
    return


ones = slv2xyz(infile)
prepend('{}'.format(ones), 'myout.xyz')
