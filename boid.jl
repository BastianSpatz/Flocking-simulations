# Boid struct 
mutable struct Boid
    id
    position
    velocity
    acceleration
end

# limit the magnitude of a 2-d Array to lim
function set_limit!(v::Array, lim::Float64)
    n = sqrt(sum(v.^2))
    f = min(n, lim)/n
    return v .* f
end

# set the magnitude of a 2-d Array to mag
function set_magnitude!(v::Array, mag::Float64)
    n = sqrt(sum(v.^2))
    f = max(n, mag)/n
    return v .* f
end

# flap updates the acceleration of each boid
function flap!(boid::Boid, flock::Vector{Boid}, alignValue, separationValue, cohesionValue)
    boid.acceleration += align!(boid, flock) .* alignValue
    boid.acceleration += seperate!(boid, flock) .* separationValue
    boid.acceleration += cohese!(boid, flock) .* cohesionValue
end

## fly updates the position and velocity of each boid
# each boid flaps ones per fly update
function fly!(boid::Boid, flock::Vector{Boid}, alignValue, separationValue, cohesionValue)
    maxSpeed = 4.
    flap!(boid, flock, alignValue, separationValue, cohesionValue)
    boid.position += boid.velocity
    boid.velocity += boid.acceleration
    boid.velocity = set_limit!(boid.velocity, maxSpeed)
    boid.acceleration .*= 0
end

# align Boid to its flock 
function align!(b::Boid, flock::Vector{Boid})
    maxForce = 1.
    maxSpeed = 4.
    perceptionRadius = 50
    steering = zeros(size(b.velocity))
    total = 0
    for boid in flock
        dist = b.position - boid.position
        if b.id != boid.id && norm(dist) < perceptionRadius
            steering += boid.velocity
            total +=1
        end
    end
    if total > 0
        steering ./= total
        steering = set_magnitude!(steering, maxSpeed)
        steering -= b.velocity
        steering = set_limit!(steering, maxForce)
    end
    return steering       
end

# seperate each flock from its flock s.t. they dont collide
function seperate!(b::Boid, flock::Vector{Boid})
    maxForce = 1.
    maxSpeed = 4.
    perceptionRadius = 50
    steering = zeros(size(b.velocity))
    total = 0
    for boid in flock
        dist = b.position - boid.position
        if b.id != boid.id && norm(dist) < perceptionRadius
            diff = dist / (norm(dist)^2)
            steering += diff
            total +=1
        end
    end
    if total > 0
        steering ./= total
        steering = set_magnitude!(steering, maxSpeed)
        steering -= b.velocity
        steering = set_limit!(steering, maxForce)
    end
    return steering       
end

# follow the flocks average position 
function cohese!(b::Boid, flock::Vector{Boid})
    maxForce = 1.
    maxSpeed = 4.
    perceptionRadius = 100
    steering = zeros(size(b.velocity))
    total = 0
    for boid in flock
        dist = b.position - boid.position
        if b.id != boid.id && norm(dist) < perceptionRadius
            steering += boid.position
            total +=1
        end
    end
    if total > 0
        steering ./= total
        steering -= b.position
        steering = set_magnitude!(steering, maxSpeed)
        steering -= b.velocity
        steering = set_limit!(steering, maxForce)
    end
    return steering       
end

# helper function to make boids reapear on edge hit
function edge!(b::Boid, width, height)
    if b.position[1] < 0
        b.position[1] += width
    end
    if b.position[1] > width
        b.position[1] -= width
    end
    if b.position[2] < 0
        b.position[2] += height
    end
    if b.position[2] > height
        b.position[2] -= height
    end
    if b.position[3] < 0
        b.position[3] += height
    end
    if b.position[3] > height
        b.position[3] -= height
    end
end