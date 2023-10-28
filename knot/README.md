# Knot

The script `postinstall.sh`  will install knot onto an instance. This postinstall script supports Ubuntu operating systems, and is well-tested on DLAMI Ubuntu 20.04.

Knot is a high-performance DNS resolver recommended for certain GenAI use-cases such as [img2dataset](https://github.com/rom1504/img2dataset#setting-up-a-high-performance-dns-resolver).

```yaml
 CustomActions:
    OnNodeConfigured:
      Script: https://raw.githubusercontent.com/aws-samples/aws-parallelcluster-post-install-scripts/main/knot/postinstall.sh
```
