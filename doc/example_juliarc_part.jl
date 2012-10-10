
#NOTE: this is out of date, .juliarc.jl doesn't seem to be loaded anymore
# TODO start using modules...

#For me is "proj/julia" or "oproj/julia"
directory_of_julia_projects = "Your directory" 
push(LOAD_PATH, directory_of_julia_projects)

#....

#And if you want to check that all the directories exist:
for path in LOAD_PATH #At end.
  size = filesize(path)
  assert( size>0, "Seems like path in LOAD_PATH doesn't exist.
size $size (using filesize as proxy. TODO find file_exists)")
end
