extends Node


static func remove_children(node: Node, free_children: bool = false) -> void: # removes all children from a node, optionally freeing children
	for child in node.get_children():
		node.remove_child(child)
		if free_children:
			child.queue_free()
