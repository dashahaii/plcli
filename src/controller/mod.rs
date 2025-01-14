use crate::model;
use crate::view;

pub fn handle_greet() {
    let message = model::get_greeting();
    view::display_message(&message);
}
