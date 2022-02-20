
# List of targets
# Each target has a user-defined name and an associated command to be executed 

targets = [

    { "name" : "demo1" , "command" : "echo LINE 1 && echo LINE 2 && echo LINE 30 && echo LINE 4 && echo LINE 5"  },
    { "name" : "demo2" , "command" : "echo LINE 10 && echo LINE 30 && echo LINE 40 && echo LINE 50"  },
    { "name" : "demo3" , "command" : "echo LINE 100 && echo LINE 200 && echo LINE 300 && echo LINE 400 && echo LINE 500"  },

]

run_filters_out = [ ]
diff_filters_in = [ {"name": "all", "re": "^(.*)$", "apply": "%"} ]

