-- ModuleScript: ReplicatedStorage > TopicContent
-- The order follows the stations in the lobby. Keep answer keys on the server.
local theory = game:GetService("ReplicatedStorage"):WaitForChild("Theory")
local order = { "voorrang", "verkeerstekens" }
local topics = {}

for _, topicId in ipairs(order) do
	local topic = require(theory:WaitForChild(topicId))
	assert(topic.topicId == topicId, "Topic ID must match the ModuleScript name: " .. topicId)
	topics[topicId] = topic
end

return {
	defaultTopicId = order[1],
	order = order,
	topics = topics,
}
