local M = {}

M.check = function()
	vim.health.start("lumen report")
	local info = vim.fn['lumen#debug#info']()

	if info.platform:len() then
		vim.health.ok(string.format("Platform %s is supported", info.platform))
	else
		vim.health.error("Platform is not supported")
	end

	if vim.regex('^run'):match_str(info.job_state) == nil then
		vim.health.error(string.format("Background job is not running: %s", info.job_state))
	else
		vim.health.ok("Background job is running")
	end

	if next(info.job_errors) == nil then
		vim.health.ok("No job errors reported")
	else
		vim.health.warn("Job reported errors", info.job_errors)
	end
end

return M
