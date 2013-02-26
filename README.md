dx11-vvvv-girlpower
===================

Help patches and samples for vvvv and DirectX11 nodes

![dx11-vvvv-girlpower!](https://raw.github.com/mrvux/dx11-vvvv-girlpower/master/images/ReadmeHeader.png)

# Directories

* girlpower : Various examples to demonstrate features
    * sm4 : Examples that can run on DirectX10+ hardware
    * sm5 : Examples that run only on DirectX11 hardware

* help : Help files
    * Nodes : Help files for standard nodes

* dx11 : Basic material shaders with their help files

# How to contribute

Hi, I'm fibo. The following instructions are write to let you, creative people, use the power of git. So if something is wrong please let me know.

First of all, you need a github account. It should be great that the login you get is similar to your vvvv nick.

Then install [GitHub for Windows](http://windows.github.com/) and log in from client.

You will now create your own copy of this repository, just fork it!

![fork-it!](https://raw.github.com/fibo/dx11-vvvv-girlpower/master/images/ForkIt.png)

It' s time to download your local copy, use the client and clone your repo.

![clone-it!](https://raw.github.com/fibo/dx11-vvvv-girlpower/master/images/CloneIt.png)

You can browse the file easily using explorer.

![open-in-explorer!](https://raw.github.com/fibo/dx11-vvvv-girlpower/master/images/OpenInExplorer.png)

Add your stuff, do some modifications and then commit your work. Everything will be saved to your own fork.

To let vux add your modifications, you can do a pull request.

![pull-request!](https://raw.github.com/fibo/dx11-vvvv-girlpower/master/images/PullRequest.png)

Here is the tricky part, unfortunately I' ve found no way by now to do it with the client.

Don' t panic it will be really easy, just follow my indications and open a shell.

![open-shell!](https://raw.github.com/fibo/dx11-vvvv-girlpower/master/images/OpenShell.png)

Only once, you should set the vux master repository as the upstream. In fact if you do

    git remote -v

you will something like

    origin  https://github.com/fibo/dx11-vvvv-girlpower.git (fetch)
    origin  https://github.com/fibo/dx11-vvvv-girlpower.git (push)

Add the vux repo as your `upstream`, so you will get the modifications of all the users back to your local fork. Well, trust me :)

    git remote add upstream https://github.com/mrvux/dx11-vvvv-girlpower.git

Remember, this is done only once. Now you have your upstream set properly

![git-remote-v!](https://raw.github.com/fibo/dx11-vvvv-girlpower/master/images/GitRemote.png)

So, now you can refresh your local repo with the latest goodies from the vux repo (the upstream) just typing

    git remote pull upstream

pretty easy, just use the `ghost in the shell` :)







