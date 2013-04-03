dx11-vvvv-girlpower
===================

Help patches and samples for vvvv and DirectX11 nodes

![dx11-vvvv-girlpower!](https://raw.github.com/mrvux/dx11-vvvv-girlpower/master/images/ReadmeHeader.png)

# Directories

* [girlpower](https://github.com/mrvux/dx11-vvvv-girlpower/tree/master/girlpower) : Various examples to demonstrate features
    * [sm4](https://github.com/mrvux/dx11-vvvv-girlpower/tree/master/girlpower/sm4) : Examples that can run on DirectX10+ hardware
    * sm5 : Examples that run only on DirectX11 hardware

* [help](https://github.com/mrvux/dx11-vvvv-girlpower/tree/master/help) : Help files
    * [nodes](https://github.com/mrvux/dx11-vvvv-girlpower/tree/master/help/nodes) : Help files for standard nodes

* [dx11](https://github.com/mrvux/dx11-vvvv-girlpower/tree/master/dx11) : Basic material shaders with their help files

# How to contribute

Hi, I'm fibo. The following instructions will let you, creative people, use the power of git. So if something is wrong or you think can be improved please let me know, or even better modify this file.

First of all, *you need* a github account! It should be great that the login you get is similar to your vvvv nick.

Then install [GitHub for Windows](http://windows.github.com/) and log in from client as well as on github site.

You will now create your own copy of this repository, just fork it!

![fork-it!](https://raw.github.com/mrvux/dx11-vvvv-girlpower/master/images/ForkIt.png)

It' s time to download your own local copy, use the client and clone your repo.

![clone-it!](https://raw.github.com/mrvux/dx11-vvvv-girlpower/master/images/CloneIt.png)

After you open the repo with the client, you can browse the file easily using the explorer.

![open-in-explorer!](https://raw.github.com/mrvux/dx11-vvvv-girlpower/master/images/OpenInExplorer.png)

Add your stuff, do some modifications and then commit your work clicking the sync button. Everything will be saved to your own fork.

![commit-and-sync!](https://raw.github.com/mrvux/dx11-vvvv-girlpower/master/images/CommitAndSync.png)

To let vux know about your modifications, you can do a pull request.

![pull-request!](https://raw.github.com/mrvux/dx11-vvvv-girlpower/master/images/PullRequest.png)

It will arrive a notification to vux that will merge your modifications to its master repo.

Let me add some advice, that can seem trivial but could save a lot of time:

* do small modifications, commit often
* put some short explicative comment about your commit
* comunicate with other contributors, you could discuss about your modification before doing it
* please respect conventions, if any :)

So, suppose your contribution was received and it is now part of the official dx11 girlpower or you just want to update your local repo with the last version of the original vux repo.

This is the tricky part, unfortunately I' ve found no way by now to do it with the client.

Don' t panic it will be really easy, just follow my indications and open a shell.

![open-shell!](https://raw.github.com/mrvux/dx11-vvvv-girlpower/master/images/OpenShell.png)

Only once, you should set the mrvux/dx11-vvvv-girlpower master repository as the upstream. In fact if you do

    git remote -v

you will see some output like

    origin  https://github.com/fibo/dx11-vvvv-girlpower.git (fetch)
    origin  https://github.com/fibo/dx11-vvvv-girlpower.git (push)

Add the vux repo as your `upstream, so you will get the modifications of all the users back to your local fork. Well, trust me :)

    git remote add upstream https://github.com/mrvux/dx11-vvvv-girlpower.git

Remember, this is done only once. Now you have your upstream set properly

![git-remote-v!](https://raw.github.com/mrvux/dx11-vvvv-girlpower/master/images/GitRemote.png)

So, now you can refresh your local repo with the latest goodies from the vux repo (the upstream) just typing

    git pull upstream master

pretty easy, just use the `ghost in the shell` :)

I will look for some git hook or transparent user solution to avoid the upstream step.

