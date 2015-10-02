---
name: AmendTheConfigurationAndPushAgain
.left-column[
  ### Configure CircleCI 
.footnote[.red.bold[] [Table of Contents](./)] 
<!-- H -->]
.right-column[
~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ - o 0 o - ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~

#### Amend the Configuration and Push Again

The command failed because we still to reference our package from the ```circle.yml``` file.  We have to add these lines (substituting appropriately for your names) . . .
```ruby
    - mkdir -p ~/packages/yourself;  # ensure dir exists
    - pushd ~/packages/yourself;     
        git clone https://github.com/your0rg/yourpackage;
      popd;
    - pushd ./packages;
        rm -fr yourpackage;
        ln -s ~/packages/yourself/yourpackage yourpackage;
      popd;
```
. . . just after this one, and then commit and push again.
```ruby
    - ln -s ~/node_modules node_modules
```
#####Commands
```terminal
git commit -am 'clone pkg and link to it' && git push
```


<!-- Code for this begins at line #48 -->
<!-- B -->
.center[.footnote[.red.bold[] <a href="https://github.com/martinhbramwell/Meteor-CI-Tutorial/blob/master/Part06_CloudContinuousIntegration.sh#L48" target="_blank">Code for this step.</a>] ]
]