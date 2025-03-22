import readline { Readline }

fn confirm(question string) !bool {
	mut r := Readline{}
	answer := r.read_line('${question}? [Y/n]: ')!
	println('')
	return answer == '' || answer == 'y' || answer == 'Y'
}
