# on_destroy terraform module

In order to run terraform provisioners during the destroy operation, we can use the `when = destroy` option.

https://www.terraform.io/docs/provisioners/index.html#destroy-time-provisioners

The major issue (and the "why" of this module) is that interpolation of variables is not allowed for destroy time provisioners.
This is a big issue, as some of the parameters of the connection entries (user, password, private_key) are passed by the user as variable.

So we couldn't use this piece of code for example because `var` is declared:

```
connection {
  host        = element(aws_instance.netweaver.*.public_ip, count.index)
  type        = "ssh"
  user        = "ec2-user"
  private_key = var.private_key
}
```


## References

https://github.com/hashicorp/terraform/issues/23679
https://github.com/hashicorp/terraform/pull/23559
https://github.com/hashicorp/terraform/pull/24083
