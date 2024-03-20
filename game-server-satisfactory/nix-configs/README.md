# Nixos Config

This directory represents an example of how to set up a Satisfactory server on NixOS. This is much better than my initial [simple-ubuntu-configs/](../simple-ubuntu-configs/README.md) deployment of satisfactory. NixOS represents an Infrastructure as Code (IaC), or really Configuration as Code (CaC??). Which given the host a massive ability to control what is deployed, and manage that in git (or other source control) instead of manually changing somethings on the server.

To back up a bit and really step onto a soap box for a paragraph. [Infrastructure as Code](https://aws.amazon.com/what-is/iac/) is a time savings way to manage resources. If its in code, or really in git (or other source control), that can be tracked. Rolled back. Branched. Or any other 'action' expected of modern software design. With Infrastructure as Code there is no question of what was deployed. The same thing can be deployed to multiple places with the exact same structures and results. The security savings are also massive. Static code analysis tools can be let loose on infrastructure if that infrastructure is in code. Meaning I can get warnings if the combination of settings I am about to do is either missing a critical security piece, or is plain inefficient.

Now realistically, what I have going on here is not a massive cost savings by deploying with Infrastructure as Code. But what it does do is build the foundations for my later ability to [spin 100% of my non-core infrastructure using automation like GitHub actions, or other CI/CD runner](https://www.youtube.com/watch?v=tIWDpG7sNTU). Having this automation trigger on detection of a change to my infrastructure. Meaning I can spin up, spin down, and roll back, *automagically*.

This rant may move somewhere else, maybe a dedicated rants folder at the root.

## Relative Folder Structure

- [*root directory*](../../README.md)
  - [/game-server-satisfactory](../README.md)
    - [nix-configs/](./README.md) - ***YOU ARE HERE***
      - `example-secrets.nix` - Set of configuration settings which are best left secret.
      - `satisfactory.nix` - Core Nix config which sets up Satisfactory.
      - `system-configs.nix` - Core system configuration settings.
    - [simple-ubuntu-configs/](../simple-ubuntu-configs/README.md)
