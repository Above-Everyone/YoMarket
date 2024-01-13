module src

import os
import time
import src.items
import src.profiles

pub struct Guide 
{
	pub mut:
		query 		string
		item_c		int
		raw_items	[]string
		items		[]items.Item

		profile_c	int
		profiles	[]profiles.Profile
}

pub enum ResultType
{
	_none					= 0
	_exact 					= 1
	_extra 					= 2
	_item_failed_to_update	= 3
	_item_updated			= 4
}

pub struct Response
{
	pub mut:
		r_type		ResultType
		results		[]items.Item
}

pub fn build_guide() Guide 
{
	mut g := Guide{}
	db := os.read_lines("db/items.txt") or { [] }
	profile_dir := os.ls("db/profiles/") or { [] }

	if db == [] ||  profile_dir == [] {
		println("[ X ] Error, Unable to load databases...!")
		return Guide{}
	}

	g.raw_items = db
	println("[ + ] Loading item database...!")

	mut item_c := 0
	for item in db
	{
		item_info := g.parse(item)

		/* 
		/ Detecting the following db format line
		/ ('item_name','item_id','item_url','item_price','item_update','is_tradable','is_giftable','in_store','store_price')
		*/

		if item_info.len >= 4 {
			mut new_itm := items.new(item_info)
			new_itm.idx = item_c
			g.items << new_itm
			item_c++
		}
	}

	g.profile_c = g.profiles.len

	println("Item database successfully loaded...!\nLoading profile database...!")

	// mut c := 0
	// for user in profile_dir 
	// {
	// 	if user.contains("example") { continue }
	// 	g.profiles << profiles.new(os.read_file("db/profiles/${user}") or { "" })
	// 	c++
	// } 

	return g
}

pub fn (mut g Guide) find_profile(username string) profiles.Profile
{
	if username.len < 1 { return profiles.Profile{} }
	for user in g.profiles 
	{
		if user.username == username { return user }
	}

	return profiles.Profile{}
}

pub fn (mut g Guide) search(query string) Response
{
	mut r := Response{r_type: ResultType._none, results: []items.Item{}}

	if query.int() > 0 {
		find := g.find_by_id()

		if find.name != "" {
			return Response{r_type: ResultType._exact, results: [find]}
		}
	}

	find := g.find_by_name()

	if find.len == 1 {
		return Response{r_type: ResultType._exact, results: [find[0]]}
	} else if find.len > 1 {
		return Response{r_type: ResultType._extra, results: find}
	}

	return Response{r_type: ResultType._none, results: []items.Item{} }
}

pub fn (mut g Guide) find_by_name() []items.Item
{
	mut found := []items.Item{}

	for mut item in g.items 
	{
		if item.name == g.query { return [item] }

		if item.name.to_lower().contains(g.query) {
			found << item
		}
	}

	return found
}

pub fn (mut g Guide) advanced_match_name(item_name string) bool 
{
	words_in_item_name := item_name.to_lower().split(" ")
	words_in_search_name := g.query.to_lower().split(" ")

	for word in words_in_item_name
	{
		for search_word in words_in_search_name
		{
			if word.contains(search_word) || word.starts_with(search_word) || word.ends_with(search_word) { return true }
		}
	}

	return false
}

pub fn (mut g Guide) find_by_id() items.Item
{
	for item in g.items
	{
		if "${item.id}" == "${g.query}" { return item }
	}

	return items.Item{}
}

pub fn (mut g Guide) change_price(mut item items.Item, new_price string) bool 
{
	mut db := os.open_file("db/items.txt", "w") or { os.File{} }
	current_time := "${time.now()}".replace("-", "/").replace(" ", "-")
	item.price = new_price
	item.update = current_time

	g.raw_items[item.idx] = "('${item.name}','${item.id}','${item.url}','${item.price}','${item.update}')"
	for line in g.raw_items
	{
		db.write("${line}\n".bytes()) or { 0 }
	}

	db.close()
	return true
}

pub fn (mut g Guide) add_new_profile(args ...string) bool
{
	mut c := profiles.create()
	if c.username == "" { return false }

	g.profiles << c
	return true
}

pub fn (mut g Guide) add_to_list(list_t profiles.List_T, data string) bool
{
	match list_t
	{
		.add_fs {

		}
		.rm_fs {

		}
		.add_wtb {

		}
		.rm_wtb {

		} else {}
	}

	return true
}

fn (mut g Guide) parse(line string) []string
{
	return line.replace("(", "").replace(")", "").replace("'", "").split(",")
}