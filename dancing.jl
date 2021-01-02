using GLMakie
using AbstractPlotting
using AbstractPlotting.MakieLayout
using LinearAlgebra
using  Distributions


struct Dancer
    position
    velocity
end

struct Dance
    flock::Vector{Dancer}
    friends::Vector{Int}
    enemies::Vector{Int}
    center
end

# 1000 dancer assume random positions
# randomly chooses 1 friend and one enemy 
# at each step every dancer:
    # moves 0.5% closer to the centre of the floor
    # takes a large step towards their friend
    # small step away from their enemy
# at random interval one dancer rechooses their friend and enemy

function aim(d::Dancer, target::Dancer, speed::Real)
    if d.position == target.position
        direction = zeros(size(d.position))
    else 
        v = target.position - d.position
        direction = v/norm(v)
    end 
    return direction * speed
end 

function flap!(d::Dancer, v)
    d.velocity .+= v
end

function fly!(d::Dancer)
    d.position .+= d.velocity
    d.velocity .*= 0
end

function Dance(flock::Vector{Dancer})
    origin = zeros(size(flock[1].position))
    N = size(flock, 1)
    friends = rand(1:N, N)
    enemies = rand(1:N, N)
    return Dance(flock, friends, enemies, origin)
end

function dancestep!(d::Dance, friend_step_size, enemy_step_size)
    #origin = Dancer(d.center, zeros(size(d.center)))
    for i in 1:size(d.flock, 1)
        friend_v = aim(d.flock[i], d.flock[d.friends[i]], friend_step_size)
        enemy_v = aim(d.flock[i], d.flock[d.enemies[i]], enemy_step_size)
        #center_v = aim(d.flock[i], origin, 0.05 * norm(origin.position - d.flock[i].position) )
        v = friend_v - enemy_v - 0.05* norm(d.flock[i].position)^2 .* d.flock[i].position
        flap!(d.flock[i], v)
        fly!(d.flock[i])
    end
end

function new_partners!(d::Dance, K::Int)
    N = size(d.flock, 1)
    dancers = rand(1:N, K)
    new_friends = rand(1:N, K)
    new_enemies = rand(1:N, K)
    
    d.friends[dancers] .= new_friends
    d.enemies[dancers] .= new_enemies
end

## init ##
n = 500 
flock = [Dancer(randn(3), randn(3)) for i=1:n];
dance = Dance(flock);

width = height = 500;
plot(d::Dance) = [Point3f0(dancer.position) for dancer in d.flock];
dots = Node(plot(dance));

scene = Scene()
scatter!(scene, dots, markersize=12, color="black")

s_f, friend_step_size = textslider(0:0.001:0.1, "friend"; start=0.1)
s_e, enemy_step_size = textslider(0:0.001:0.1, "enemy"; start=0.05)

# display(vbox(hbox(s_f, s_e), scene))
xlims!(scene, (-1.5, 1.5))
ylims!(scene, (-1.5, 1.5))
zlims!(scene, (-1.5, 1.5))
display(scene)
cam3d!(scene, lookat=[0, 0, 0], eyeposition = [1.5, 1, 1] .* 0.5)
# @async while isopen(scene)
#     K = rand(Poisson())
#     new_partners!(dance, K)
#     dancestep!(dance, friend_step_size[], enemy_step_size[])
#     dots[] = plot(dance)
#     # plot the dots[]
#     sleep(0.03)
# end
# display(scene)

frames = 1:(60 * 60)
record(scene, "Dance_3d.gif", frames; framerate = 60) do frame
    K = rand(Poisson())
    new_partners!(dance, K)
    dancestep!(dance, 0.067, 0.04)
    dots[] = plot(dance)
    # plot the dots[]
    sleep(0.03)
end