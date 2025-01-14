mod model;
mod view;
mod controller;
 
use clap::Parser;

#[derive(Parser)]
#[command(name = "Day Planner")]
#[command(about = "A simple command-line day planner", version = "1.0")]
struct Cli {
    #[arg(short, long, help = "The action to perform (e.g., 'greet')")]
    action: String,
}

fn main() {
    let cli = Cli::parse();

    if cli.action == "greet" {
        controller::handle_greet();
    } else {
        println!("Unknown action: {}", cli.action);
    }
}