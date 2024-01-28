module profiles

import time

import src.items
import src.utils
// import crypto.bcrypt

/*
	[@DOC]

	Create a new Profile with 
*/
pub fn create(args ...string) Profile
{
	if args.len != 14 { return Profile{} }

	mut p := Profile{}
	mut set_info := [p.username, p.password, p.yoworld, "${p.yoworld_id}",
				p.net_worth, p.discord, "${p.discord_id}", p.facebook, p.facebook_id]

	mut c := 0
	for mut arg in set_info
	{
		arg = args[c]
		c++
	}

	p.invo = []items.Item{}
	p.fs_list = []FS{}
	p.wtb_list = []WTB{}

	return p
}

pub fn new(p_content string) Profile
{
	if p_content.len < 1 { return Profile{} }

	// TO-DO: Syntax Checker Function Call Here 

	mut p := Profile{}
	lines := p_content.split("\n")
	
	mut line_c := 0 
	for line in lines 
	{
		line_arg := line.trim_space().split(":")
		match line 
		{
			utils.match_starts_with(line, "username:") {
				if line_arg.len > 0 { p.username = line_arg[1].trim_space() }
			}
			utils.match_starts_with(line, "password:") {
				if line_arg.len > 0 { p.password = line_arg[1].trim_space() }
			}
			utils.match_starts_with(line, "yoworld:") {
				if line_arg.len > 0 { p.yoworld = line_arg[1].trim_space() }
			}
			utils.match_starts_with(line, "yoworldID:") {
				if line_arg.len > 0 { p.yoworld_id = line_arg[1].trim_space().int() }
			}
			utils.match_starts_with(line, "netWorth:") {
				if line_arg.len > 0 { p.net_worth = line_arg[1].trim_space() }
			}
			utils.match_starts_with(line, "discord:") {
				if line_arg.len > 0 { p.discord = line_arg[1].trim_space() }
			}
			utils.match_starts_with(line, "discordID:") {
				if line_arg.len > 0 { p.discord_id = line_arg[1].trim_space().i64() }
			}
			utils.match_starts_with(line, "facebook:") {
				if line_arg.len > 0 { p.facebook = line_arg[1].trim_space() }
			}
			utils.match_starts_with(line, "facebookID:") {
				if line_arg.len > 0 { p.facebook_id = line_arg[1].trim_space() }
			}
			utils.match_starts_with(line, "[@ACTIVITIES]") {
				p.activites = p.parse_activities(p_content, line_c)
			}
			utils.match_starts_with(line, "[@INVENTORY]") {
				p.invo = p.parse_invo(p_content, line_c)
			}
			utils.match_starts_with(line, "[@FS]") {
				p.fs_list = p.parse_fs(p_content, line_c)
			}
			utils.match_starts_with(line, "[@WTB]") {
				p.wtb_list = p.parse_wtb(p_content, line_c)
			} else {}
		}
		line_c++
	}

	return p
}

/*
	pub fn (mut p Profile) edit_settings(setting_t Settings_T, new_data string) bool

	Description:
		Edit a Profile's Settings
*/
pub fn (mut p Profile) edit_settings(setting_t Settings_T, new_data string) bool
{
	if new_data.len < 1 { return false }
	match setting_t
	{
		.username {
			p.username = new_data
		}
		.password {
			// Add encryption here
			p.password = new_data
		}
		.yoworld {
			p.yoworld = new_data
		}
		.yoworld_id {
			p.yoworld_id = new_data.int()
		}
		.net_worth {
			p.net_worth = new_data
		}
		.discord {
			p.discord = new_data
		}
		.discord_id {
			p.discord_id = new_data.i64()
		}
		.facebook {
			p.facebook = new_data
		}
		.facebook_id {
			p.facebook_id = new_data
		} else {}
	}

	return true
}

/*
	pub fn (mut p Profile) edit_list(settings_t Settings_T, 
									acti_t Activity_T, 
									mut itm items.Item, 
									args ...string) bool

	Description:
		Edit a profile list type ( Add/Remove INVO/FS/WTB )
*/
pub fn (mut p Profile) edit_list(settings_t Settings_T, acti_t Activity_T, mut itm items.Item, args ...string) bool
{
	current_time := "${time.now()}".replace("-", "/").replace(" ", "-")
	match settings_t 
	{
		.add_to_invo {
			p.invo << itm
			p.activites << new_activity(acti_t, mut itm, args[0], current_time, p.activites.len+1, args[1], args[2])
		}
		.add_to_fs {
			p.fs_list << FS{ posted_timestamp: current_time, fs_price: args[0], item: itm }
			p.activites << new_activity(acti_t, mut itm, args[0], current_time, p.activites.len+1, args[1], args[2])
		}
		.add_to_wtb {
			p.wtb_list << WTB{ posted_timestamp: current_time, wtb_price: args[0], item: itm }
			p.activites << new_activity(acti_t, mut itm, args[0], current_time, p.activites.len+1, args[1], args[2])
		}
		.rm_from_invo {
			mut c := 0
			for mut invo_item in p.invo 
			{
				if invo_item.id == itm.id {
					p.invo.delete(c)
				}
				c++
			}
			p.activites << new_activity(acti_t, mut itm, args[0], current_time, p.activites.len+1, args[1], args[2])
		}
		.rm_from_fs {
			mut fs_c := 0
			for mut fs_item in p.fs_list 
			{
				if fs_item.item.id == itm.id {
					p.fs_list.delete(fs_c)
				}
				fs_c++
			}
			p.activites << new_activity(acti_t, mut itm, args[0], current_time, p.activites.len+1, args[1], args[2])
		}
		.rm_from_wtb {
			mut wtb_c := 0
			for mut wtb_item in p.wtb_list 
			{
				if wtb_item.item.id == itm.id {
					p.wtb_list.delete(wtb_c)
				}
				wtb_c++
			}
			p.activites << new_activity(acti_t, mut itm, args[0], current_time, p.activites.len+1, args[1], args[2])
		} else { return false }
	}
	return false
}

/*
	pub fn (mut p Profile) parse_activities(content string, line_n int) []Activity

	Description:
		Parsing all activities within a Profile's DB File
*/
pub fn (mut p Profile) parse_activities(content string, line_n int) []Activity
{
	
	mut new := []Activity{}
	mut lines := content.split("\n")
	for i in line_n+1..(lines.len)
	{
		if lines[i].trim_space() == "}" || lines[i].trim_space() == "" || lines[i].contains("}") { break }
		if lines[i].contains("{") == false { 

			activity_info := lines[i].split(",")
			mut n_itm := items.new(activity_info[2..7])
			match activity_info[1].trim_space()
			{
				"SOLD" {
					mut n := new_activity(Activity_T.item_sold, mut n_itm, activity_info[7], activity_info[activity_info.len-1], new.len+1, activity_info[activity_info.len-2], activity_info[activity_info.len-1])
					new << n
				}
				"BOUGHT" {
					mut n := new_activity(Activity_T.item_bought, mut n_itm, activity_info[7], activity_info[activity_info.len-1], new.len+1, activity_info[activity_info.len-2], activity_info[activity_info.len-1])
					new << n
				}
				"VIEWED" {
					mut n := new_activity(Activity_T.item_viewed, mut n_itm, "", activity_info[activity_info.len-1], new.len+1)
					new << n
				}
				"CHANGED" {
					mut n := new_activity(Activity_T.price_change, mut n_itm, activity_info[7], activity_info[activity_info.len-1], new.len+1)
					new << n
				} else {}
			}
		}
	}

	return new
}

/*
	pub fn (mut p Profile) parse_invo(content string, line_n int) []items.Item

	Description:
		Parsing all inventory within a Profile's DB File
*/
pub fn (mut p Profile) parse_invo(content string, line_n int) []items.Item
{
	
	mut new := []items.Item{}
	mut lines := content.split("\n")
	for i in line_n+1..(lines.len)
	{
		if lines[i].trim_space() == "}" { break }
		if lines[i].trim_space() == "" { continue }
		if lines[i].contains("{") == false { 
			new << items.new(lines[i].split(","))
		}
	}

	return new
}

/*
	pub fn (mut p Profile) parse_fs(content string, line_n int) []FS

	Description:
		Parsing all FS within a Profile's DB File
*/
pub fn (mut p Profile) parse_fs(content string, line_n int) []FS
{
	mut new := []FS{}
	mut lines := content.split("\n")
	
	for i in line_n+1..(lines.len)
	{
		if lines[i].trim_space() == "}" || lines[i].trim_space() == "" || lines[i].contains("}") { break }
		if lines[i].contains("{") == false { 
			fs_item_info := lines[i].split(",")
			if fs_item_info.len < 2 { continue }

			mut new_wtb := FS{}
			new_wtb.item = items.new(fs_item_info[0..5])
			new_wtb.fs_price = fs_item_info[fs_item_info.len-2]
			new_wtb.posted_timestamp = fs_item_info[fs_item_info.len-1]

			new << new_wtb
		}
	}

	return new
}

/*
	pub fn (mut p Profile) parse_wtb(content string, line_n int) []WTB 

	Description:
		Parsing all WTB within a Profile's DB File
*/
pub fn (mut p Profile) parse_wtb(content string, line_n int) []WTB 
{
	mut new := []WTB{}
	mut lines := content.split("\n")

	for i in line_n+1..(lines.len)
	{
		if lines[i].trim_space() == "}" { break }
		if lines[i].trim_space() == "" { continue }
		if lines[i].contains("{") == false { 
			wtb_item_info := lines[i].split(",")

			mut new_wtb := WTB{}
			new_wtb.item = items.new(wtb_item_info[0..(wtb_item_info.len-3)])
			new_wtb.wtb_price = wtb_item_info[wtb_item_info.len-2]
			new_wtb.posted_timestamp = wtb_item_info[wtb_item_info.len-1]

			new << new_wtb
		}
	}

	return new
}

pub fn (mut p Profile) profile2str() string
{
	mut data := "[@PROFILE] => ${p.username}
              PW => ${p.password}
              Yoworld => ${p.yoworld}
              Yoworld ID => ${p.yoworld_id}
              Net Worth => ${p.net_worth}
              Discord => ${p.discord}
              Discord ID => ${p.discord_id}
              Facebook => ${p.facebook}
              Facebook ID => ${p.facebook_id}

          [ @DIPLAY_SETTINGS ]
   Badges => ${p.display_badges} | Worth => ${p.display_worth} | INVO => ${p.display_invo} | FS => ${p.display_fs} | WTB => ${p.display_wtb} | Activity => ${p.display_activity}\n"

   data += "[@ACTIVITIES]\n"

	for mut activity in p.activites 
	{
		data += "${activity.activity2str()}\n".replace("(", "").replace(")", "").replace("'", "")
	}

	data += "[@INVENTORY]\n"

	for mut invo_item in p.invo 
	{
		gg := invo_item.item2str(' | ')
		data += "${gg}\n"
	}

	data += "[@FS]\n"

	for mut fs_item in p.fs_list 
	{
		gg := fs_item.item.item2str(' | ')
		data += "${gg},${fs_item.fs_price},${fs_item.posted_timestamp}\n"
	}

	data += "[@WTB]\n"

	for mut wtb_item in p.wtb_list 
	{
		gg := wtb_item.item.item2str(' | ')
		data += "${gg},${wtb_item.wtb_price},${wtb_item.posted_timestamp}\n"
	}

	return data
}

pub fn (mut p Profile) profile2api() string 
{
	acct_info := "[${p.username},none,${p.yoworld},${p.yoworld_id},${p.net_worth},${p.discord},${p.discord_id},${p.facebook},${p.facebook_id}]"
	acct_settings := "[${p.display_badges},${p.display_worth},${p.display_invo},${p.display_fs},${p.display_wtb},${p.display_activity}]"

	mut activities := "[@ACTIVITIES]"

	for mut activity in p.activites 
	{
		activities += "${activity.activity2str()}\n"
	}

	mut invo := "[@INVENTORY]"

	for mut invo_item in p.invo 
	{
		invo += "${invo_item.item2api()}\n"
	}

	mut fs_list := "[@FS]"

	for mut fs_item in p.fs_list 
	{
		fs_list += "${fs_item.item.item2api()},${fs_item.fs_price},${fs_item.posted_timestamp}\n"
	}

	mut wtb_list := "[@WTB]"

	for mut wtb_item in p.wtb_list 
	{
		wtb_list += "${wtb_item.item.item2api()},${wtb_item.wtb_price},${wtb_item.posted_timestamp}\n"
	}

	return "${acct_info}\n${acct_settings}\n${activities}\n${invo}\n${fs_list}\n${wtb_list}".replace("(", "").replace(")", "").replace("[", "").replace("]", "").replace("'", "")
}

pub fn (mut p Profile) auth2str() string
{
	acct_info := "[${p.username},${p.password},${p.yoworld},${p.yoworld_id},${p.net_worth},${p.discord},${p.discord_id},${p.facebook},${p.facebook_id}]"
	acct_settings := "[${p.display_badges},${p.display_worth},${p.display_invo},${p.display_fs},${p.display_wtb},${p.display_activity}]"

	mut activities := "[@ACTIVITIES]"

	for mut activity in p.activites 
	{
		activities += "${activity.activity2str()}\n"
	}

	mut invo := "[@INVENTORY]"

	for mut invo_item in p.invo 
	{
		invo += "${invo_item.item2api()}\n"
	}

	mut fs_list := "[@FS]"

	for mut fs_item in p.fs_list 
	{
		fs_list += "${fs_item.item.item2api()},${fs_item.fs_price},${fs_item.posted_timestamp}\n"
	}

	mut wtb_list := "[@WTB]"

	for mut wtb_item in p.wtb_list 
	{
		wtb_list += "${wtb_item.item.item2api()},${wtb_item.wtb_price},${wtb_item.posted_timestamp}\n"
	}

	return "${acct_info}\n${acct_settings}\n${activities}\n${invo}\n${fs_list}\n${wtb_list}".replace("(", "").replace(")", "").replace("[", "").replace("]", "").replace("'", "")
}