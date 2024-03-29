module src

import time
import src.db

pub fn (mut g Guide) search(query string, get_extra_info bool) Response
{
	g.query = query
	current_time := "${time.now()}".replace("-", "/").replace(" ", "-")

	if query.int() > 0 {
		mut find := g.find_by_id()

		if find.name != "" {
			find.add_extra_info(true)
			return Response{r_type: ResultType._exact, results: [find]}
		}

		find.id = query.int()
		find.add_extra_info(true)

		if find.name != "" {
			find.price = "n/a"
			find.update = current_time
			g.add_to_db(mut find)
			return Response{r_type: ResultType._exact, results: [find]}
		}
	}

	find := g.find_by_name()

	if find.len == 1 {
		return Response{r_type: ResultType._exact, results: find}
	} else if find.len >= 2 {
		return Response{r_type: ResultType._extra, results: find}
	}

	return Response{r_type: ResultType._none, results: []db.Item{}}
}

pub fn (mut g Guide) find_by_name() []db.Item
{
	mut found := []db.Item{}

	for mut item in g.items 
	{
		if item.name == g.query || item.name.to_lower() == g.query { return [item] }

		if g.query.split(" ").len > 1 {
			if g.advanced_match_name(item.name) {
				found << item
			}
		} else if item.name.to_lower().contains(g.query) {
			found << item
		}
	}

	return found
}

pub fn (mut g Guide) find_by_id() db.Item
{
	for item in g.items
	{
		if "${item.id}" == "${g.query}" { return item }
	}

	return db.Item{}
}

pub fn (mut g Guide) change_price(mut item db.Item, new_price string, user_ip string) bool 
{
	current_time := "${time.now()}".replace("-", "/").replace(" ", "-")
	
	new_log(App_T._site, Log_T._change, user_ip, "${item.id}", item.price, new_price)
	g.items[item.idx].price = new_price
	g.items[item.idx].update = current_time

	g.raw_items[item.idx] = "('${item.name}','${item.id}','${item.url}','${new_price}','${current_time}')"


	return true
}

pub fn (mut g Guide) advanced_match_name(item_name string) bool 
{
	words_in_item_name := item_name.to_lower().split(" ")
	words_in_search_name := g.query.to_lower().split(" ")

	mut signal := false

	query_word_count := words_in_search_name.len
	item_name_word_count := words_in_search_name.len

	mut word_c := 0
	for word in words_in_search_name
	{
		if item_name.to_lower().contains(word) || item_name.to_lower().starts_with(word) || item_name.to_lower().ends_with(word) { word_c++ }

		if word_c == query_word_count {
			return true
		}
	}

	return false
}