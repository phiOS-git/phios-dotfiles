-- ~/.config/nvim-common/lua/phi/plugins/common.lua
--
-- vim.pack specs of the plugins shared by nvim-code and nvim-notes. Each
-- profile passes this list to vim.pack.add() together with its own, so an
-- update of a shared plugin has to be run in both profiles, and both
-- lockfiles committed.
--
-- `version` is a semver range where the project tags releases, or a branch
-- where it does not; the exact revision is pinned by each profile's
-- nvim-pack-lock.json either way.

return {}
