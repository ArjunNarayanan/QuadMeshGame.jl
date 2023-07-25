using QuadMeshGame
using PyPlot
QM = QuadMeshGame

angles = 1:360
continuous_degree = QM.continuous_desired_degree.(angles)
rounded_degree = QM.rounded_desired_degree.(angles)


# fig, ax = subplots()
# ax.plot(angles, rounded_degree, label="rounded")
# ax.plot(angles, continuous_degree, label="continuous")
# ax.grid()
# ax.legend()
# fig
