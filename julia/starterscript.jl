#start script
include("findnearest.jl")
include("findneighbours.jl")
include("removeedge.jl")
include("removenode.jl")
include("gwr.jl")
include("plotgwr.jl")

using MAT
using PyPlot

#using CPUtime
file = matopen("../share/local_uniform_2d.mat")
Data = read(file, "Data")
# scatter(Data[1,:]',Data[2,:]', )

tic()
A,(),(),() = gwr(Data,100);
toc()
