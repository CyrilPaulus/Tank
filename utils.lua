function rot(x, y, alpha) 
   return x * math.cos(alpha) - y * math.sin(alpha), x * math.sin(alpha) + y * math.cos(alpha)
end