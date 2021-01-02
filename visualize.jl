using GLMakie
using AbstractPlotting
using AbstractPlotting.MakieLayout
using LinearAlgebra

include("boid.jl")

# init
width = height = 500;
numBoids = 100
flock = [Boid(i, rand(1:width, 3), randn(3).*2, randn(3)) for i=1:numBoids];
plot(flock::Vector{Boid}) = [Point3f0(boid.position) for boid in flock];
dots = Node(plot(flock));


## plotting
# layout
# outer_padding = 30
# scene, layout = layoutscene(outer_padding, resolution = (1080, 720),
#     backgroundcolor = RGBf0(0.98, 0.98, 0.98))

# ax = layout[1, 1] = LAxis(scene, title = "Flocking")
scene = Scene(show_axis=false)
# # slider
# ls1 = labelslider!(scene, "alignment:", 0:0.1:5; format = x -> "$(x)")
#   layout[2, 1] = ls1.layout
# ls2 = labelslider!(scene, "seperation:", 0:0.1:5; format = x -> "$(x)")
#   layout[3, 1] = ls2.layout
# ls3 = labelslider!(scene, "cohesion:", 0:0.1:5; format = x -> "$(x)")
#   layout[4, 1] = ls3.layout

# # set inital values for sliders
# set_close_to!(ls1[1], 0.5)
# set_close_to!(ls2[1], 1.0)
# set_close_to!(ls3[1], 0.6)

# # get slider values
alignValue = 0.5# ls1[1].value
separationValue = 1#ls2[1].value
cohesionValue = 0.6 #ls3[1].value

# plot our flock of boids
scatter!(scene, dots, markersize = 6500, color="black")
# hide axis
# hidespines!(ax)
#hidedecorations!(scene)
# display the makie scene
display(scene)

# play the animation until exit
@async while isopen(scene)
    # at max width and/or height our boids reapear on the other side
    #edge!.(flock, width, height)
    for boid in flock
        # update boids with the corresponding slider values
        fly!(boid, flock, alignValue[], separationValue[], cohesionValue[])
    end
    # get new position for dots Node
    dots[] = plot(flock)
    # plot the dots[]
    yield()
end

## for recording the scene

# frames = 1:(30 * 20)
# framerate = 45
# record(scene, "flocking.gif", frames; framerate = 30) do frame
#     # at max width and/or height our boids reapear on the other side
#     edge!.(flock, width, height)
#     for boid in flock
#         # update boids with the corresponding slider values
#         fly!(boid, flock, alignValue[], separationValue[], cohersionValue[])
#     end
#     # get new position for dots Node
#     dots[] = plot(flock)
# end