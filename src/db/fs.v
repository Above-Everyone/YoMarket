module db

pub struct FS 
{
	pub mut:
		seller					string
		posted_timestamp		string
		fs_price				string
		item					Item

		buyer_confirmation  	string
		seller_confirmation 	string
		confirmed_transaction	bool
}