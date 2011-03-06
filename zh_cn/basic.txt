== 基本技巧 ==

与其一头扎进Git命令的海洋中，不如来点基本的例子试试手。它们简单而且实用。实际
上，在开始使用Git的头几个月，我所用的从来没超出本章介绍的内容。

=== 保存状态 ===

要不来点猛的？在做之前，先为当前目录所有文件做个快照，使用：

 $ git init
 $ git add .
 $ git commit -m "My first backup"

现在如果你的编辑乱了套，恢复之前的版本：

 $ git reset --hard

再次保存状态：

 $ git commit -a -m "Another backup"

=== 添加、删除、重命名 ===

以上命令将只跟踪你第一次运行 *git add* 命令时就已经存在的文件。如果要添加新文
件或子目录，你需要告诉Git：

 $ git add readme.txt Documentation

类似，如果你想让Git忘记某些文件：

 $ git rm kludge.h obsolete.c
 $ git rm -r incriminating/evidence/

这些文件如果还没删除，Git删除它们。

重命名文件和先删除旧文件，再添加新文件的一样。也有一个快捷方式 *git mv* ，和
*mv* 命令的用法一样。例如：

 $ git mv bug.c feature.c

=== 进阶撤销/重做 ===

有时候你只想把某个时间点之后的所有改动都回滚掉，因为这些的改动是不正确的。那
么：

 $ git log

来显示最近提交列表，以及他们的SHA1哈希值:

----------------------------------
commit 766f9881690d240ba334153047649b8b8f11c664
Author: Bob <bob@example.com>
Date:   Tue Mar 14 01:59:26 2000 -0800

    Replace printf() with write().

commit 82f5ea346a2e651544956a8653c0f58dc151275c
Author: Alice <alice@example.com>
Date:   Thu Jan 1 00:00:00 1970 +0000

    Initial commit.
----------------------------------

哈希值的前几个字符足够确定一个提交；也可以拷贝粘贴完整的哈希值，键入：

 $ git reset --hard 766f

来恢复到一个指定的提交状态，并从记录里永久抹掉所有比该记录新一些的提交。

另一些时候你想简单地跳到一个旧状态。这种情况，键入：

 $ git checkout 82f5

这个操作将把你带回过去，同时也保留较新提交。然而，像科幻电影里时光旅行一样，
如果你这时编辑并提交的话，你将身处另一个现实里，因为你的动作与开始时相比是不
同的。

这另一个现实叫作“分支”（branch），之后 <<branch,我们会对这点多讨论一些>>。
至于现在，只要记住：

 $ git checkout master

会把你带到当下来就可以了。另外，为避免Git的抱怨，应该在每次运行checkout之前提
交（commit）或重置（reset）你的改动。

还以电脑游戏作为类比：

- *`git reset --hard`*: 加载一个旧记录并删除所有比之新的记录。

- *`git checkout`*: 加载一个旧记录，但如果你在这个记录上玩，游戏状态将偏离第
  一轮的较新状态。你现在打的所有游戏记录会在你刚进入的、代表另一个真实的分支
  里。<<branch,我们稍后论述>>。

你可以选择只恢复特定文件和目录，通过将其加在命令之后：

 $ git checkout 82f5 some.file another.file

小心，这种形式的 *checkout* 会不声不响地覆盖文件。为阻止意外发生，在运行任何
checkout命令之前做提交，尤其在初学Git的时候。通常，任何时候你觉得对运行某个命
令不放心，无论Git命令还是不是Git命令，就先运行一下 *git commit -a* 。

不喜欢拷贝站题哈希值？那就用：

 $ git checkout :/"My first b"

来跳到以特定字符串开头的提交。你也可以回到倒数第五个保存状态：

 $ git checkout master~5

=== 撤销 ===

在法庭上，事件可以从法庭记录里敲出来。同样，你可以检出特定提交以撤销。

 $ git commit -a
 $ git revert 1b6d

讲撤销给定哈希值的提交。本撤销被记录为一个新的提交，你可以通过运行 *git log*
来确认这一点。

=== 变更日志生成 ===

一些项目要求生成变更日志http://en.wikipedia.org/wiki/Changelog[changelog]. 生
成一个，通过键入：

 $ git log > ChangeLog

=== 下载文件 ===

得到一个由Git管理的项目的拷贝，通过键入：

 $ git clone git://server/path/to/files

例如，得到我用来创建该站的所有文件：

 $ git clone git://git.or.cz/gitmagic.git

我们很快会对 *clone* 命令谈的很多。

=== 到最新 ===

如果你已经使用 *git clone* 命令得到了一个项目的一份拷贝，你可以更新到最新版，
通过：

 $ git pull

 
=== 快速发布 ===

假设你写了一个脚本，想和他人分享。你可以只告诉他们从你的计算机下载，但如果此
时你正在改进你的脚本，或加入试验性质的改动，他们下载了你的脚本，他们可能由此
陷入困境。当然，这就是发布周期存在的原因。开发人员可能频繁进行项目修改，但他
们只在他们觉得代码可以见人的时候才择时发布。

用Git来完成这项，需要进入你的脚本所在目录：

 $ git init
 $ git add .
 $ git commit -m "First release"

然后告诉你的用户去运行：

 $ git clone your.computer:/path/to/script

来下载你的脚本。这要假定他们有ssh访问权限。如果没有，需要运行 *git daemon* 并
告诉你的用户去运行：

 $ git clone git://your.computer/path/to/script

从现在开始，每次你的脚本准备好发布时，就运行：

 $ git commit -a -m "Next release"

并且你的用户可以通过进入包含你脚本的目录，并键入下列命令，来更新他们的版本：

 $ git pull

你的用户永远也不会取到你不想让他们看到的脚本版本。显然这个技巧对所有的东西都
是可以，不仅是对脚本。


=== 我们已经做了什么？ ===

找出自从上次提交之后你已经做了什么改变：

 $ git diff

或者自昨天的改变：

 $ git diff "@{yesterday}"

或者一个特定版本与倒数第二个变更之间：

 $ git diff 1b6d "master~2"

输出结果都是补丁格式，可以用 *git apply* 来把补丁打上。也可以试一下：

 $ git whatchanged --since="2 weeks ago"

我也经常用http://sourceforge.net/projects/qgit[qgit] 浏览历史, 因为他的图形界
面很养眼，或者 http://jonas.nitro.dk/tig/[tig] ，一个文本界面的东西，很慢的网
络状况下也工作的很好。也可以安装web 服务器，运行 *git instaweb* ，就可以用任
何浏览器浏览了。

=== 练习 ===

比方A，B，C，D是四个连续的提交，其中B与A一样，除了一些文件删除了。我们想把这
些删除的文件加回D。我们如何做到这个呢？

至少有三个解决方案。假设我们在D：

  1. A与B的差别是那些删除的文件。我们可以创建一个补丁代表这些差别，然后吧补丁
     打上：

   $ git diff B A | git apply

  2. 既然这些文件存在A，我们可以把它们拿出来：

   $ git checkout A foo.c bar.h

  3. 我们可以把从A到B的变化视为可撤销的变更：

   $ git revert B

哪个选择最好？这取决于你的喜好。利用Git满足自己需求是容易，经常还有多个方法。
