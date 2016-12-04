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


def frac2xyzM(crystal_prms):

    def cosd(deg):
        return np.cos(deg/180. * np.pi)

    def sind(deg):
        return np.sin(deg/180. * np.pi)

    a = crystal_prms['a']
    b = crystal_prms['b']
    c = crystal_prms['c']
    alpha = crystal_prms['alpha']
    beta = crystal_prms['beta']
    gamma = crystal_prms['gamma']
    v = np.sqrt(1-cosd(alpha)**2-cosd(beta)**2-cosd(gamma)**2 + 2*cosd(alpha)* cosd(beta)*cosd(gamma))
    r1 = [a, b*cosd(gamma), c*cosd(beta)]
    r2 = [0, b*sind(gamma), c*(cosd(alpha)-cosd(beta)*cosd(gamma))/sind(gamma)]
    r3 = [0, 0, c*v/sind(gamma)]
    M = np.array([r1, r2, r3])
    return M


def slv2xyz(infile):
    with open(infile, 'r') as fin:
        with open('myout.xyz', 'w') as fout:

            Nx = None
            Ny = None
            Nz = None
            j = 0
            ones = 0

            for line in fin:

                # Get grid specs
                if line[0:4]=='CELL':
                    _, a, b, c, alpha, beta, gamma = line.split()
                    a,b,c, alpha, beta, gamma = map(float, [a,b,c, alpha, beta, gamma])

                    # tranformation matrix to convert fractional to Cartesian
                    crystal = {}
                    crystal['a'] = a
                    crystal['b'] = b
                    crystal['c'] = c
                    crystal['alpha'] = alpha
                    crystal['beta'] = beta
                    crystal['gamma'] = gamma
                    M = frac2xyzM(crystal)

                if line[0:4]=='SIZE':
                    _, Nx, Ny, Nz = line.split()
                    Nx,Ny,Nz = map(int, [Nx,Ny,Nz])

                    # fractional coordinates
                    xarr_edges = np.linspace(0, 1, Nx+1)
                    yarr_edges = np.linspace(0, 1, Ny+1)
                    zarr_edges = np.linspace(0, 1, Nz+1)

                    xarr = 0.5 * (xarr_edges[1:] + xarr_edges[:-1])
                    yarr = 0.5 * (yarr_edges[1:] + yarr_edges[:-1])
                    zarr = 0.5 * (zarr_edges[1:] + zarr_edges[:-1])

                # Split line into characters
                chars = list(line.rstrip())

                # Process line if it contains void data
                if len(chars)==Nx:
                    for i, char in enumerate(chars):
                        if char=='1':
                            x,y,z = np.dot(M, np.array([xarr[i], yarr[j%Ny], zarr[j//Ny]]))
                            fout.write('{} {} {} {}\n'.format('C', x, y, z))
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


infile = sys.argv[1]
ones = slv2xyz(infile)
prepend('{}'.format(ones), 'myout.xyz')
