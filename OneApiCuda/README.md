
# [Compiling With DPC++ for CUDA](https://codeplay.com/solutions/oneapi/for-cuda/)

The following command can be used to compile your code using DPC++ for CUDA:
```
clang++ -fsycl -fsycl-targets=nvptx64-nvidia-cuda simple-sycl-app.cpp -o simple-sycl-app-cuda
```

Note there is a specific flag for using the CUDA target `-fsycl-targets=nvptx64-nvidia-cuda` that is used.