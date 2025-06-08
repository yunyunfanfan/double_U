# 如何将Git分支从master改为main
如果发现明明推送成功但是gitlab就是不显示, 大概率是分支默认的master, 需要删除master分支并且重新pull拉取代码之后解决版本冲突之后, 修改默认的分支为main, 重新push代码  
您可以通过以下步骤将分支名从master改为main：

## 本地分支重命名步骤

1. **创建新的main分支**（基于当前master分支）
```bash
git branch -m master main
```

这条命令会将当前的master分支重命名为main。

## 远程仓库设置

2. **推送新分支到远程仓库**
```bash
git push -u origin main
```

3. **在远程仓库中设置默认分支**
   - 登录到GitLab
   - 进入项目 → 设置 → 仓库
   - 找到"默认分支"选项，将其更改为"main"

4. **删除远程的master分支**（可选）
```bash
git push origin --delete master
```

## 确认更改

完成后，您可以验证分支情况：
```bash
git branch -a
```

应该显示本地和远程都只有main分支了。

## 提醒

- 确保所有团队成员知晓这一变更
- 他们需要在本地执行：`git fetch` 和 `git checkout main` 
- 如果有CI/CD配置，记得更新相关配置文件中的分支名称

这样您的仓库就成功从使用master分支转换为使用main分支了。