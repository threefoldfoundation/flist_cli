import os
import net.http
import term
import json

const token_file = os.join_path(os.home_dir(), '.config', 'tfhubtoken')
const docker_username_file = os.join_path(os.home_dir(), '.config', 'dockerusername')
const config_dir = os.join_path(os.home_dir(), '.config')

const binary_location = $if windows {
	'C:\\Program Files\\flist\\flist.exe'
} $else {
	'/usr/local/bin/flist'
}

const docker_cmd = $if windows {
	'docker'
} $else {
	'sudo docker'
}

const info_msg = $if windows {
	'Note: Docker Desktop must be running to use the push function.\nInstall and uninstall functions require PowerShell with administrator privileges.\nOther functions require PowerShell (without admin privileges).\n'
} $else $if linux {
	'Note: Docker Engine must be running to use the push function.\n'
} $else $if macos {
	'Note: Docker Desktop must be running to use the push function.\n'
}

const flist_repo_folder = (' # Run this line in the Flist CLI repo folder')

struct FlistItem {
	name string
}

struct Payload {
	username string
}

struct Response {
	payload Payload
}

fn add_path_windows() {
	// Define the new directory path to add
	new_path := r'C:\Program Files\flist'

	// Get the current PATH environment variable
	current_path := os.getenv('PATH')

	// Check if the new_path is already in the current PATH
	if current_path.contains(new_path) {
		println('The directory is already in the PATH.')
		return
	}

	// Construct the new PATH by appending the new_path
	new_env_path := '${current_path};${new_path}'

	// Prepare the command to set the new PATH
	cmd := r'setx PATH "' + new_env_path + '"'

	// Execute the command to update the PATH
	exit_code := os.system(cmd)

	if exit_code == 0 {
		success_message('\nFlist CLI directory added to the path. \nMake sure to load a new admin PowerShell to use the CLI.')
	} else {
		error_message('\nFailed to add the Flist CLI to the PATH. Please try running the script as an administrator.')
	}
}

fn remove_path_windows() {
	// Define the directory path to remove
	path_to_remove := r'C:\Program Files\flist'

	// Get the current PATH environment variable
	current_path := os.getenv('PATH')

	// Check if the path_to_remove is in the current PATH
	if !current_path.contains(path_to_remove) {
		println('The directory is not in the PATH.')
		return
	}

	// Remove specified directory from the PATH
	new_env_path := current_path.split(';').filter(it != path_to_remove).join(';')

	// Prepare the command to set the new PATH
	cmd := r'setx PATH "' + new_env_path + '"'

	// Execute the command to update the PATH
	exit_code := os.system(cmd)

	if exit_code == 0 {
		success_message('\nThe Flist CLI directory has been removed from the path.')
	} else {
		error_message('\nFailed to remove the Flist CLI from the PATH. Please try running the script as an administrator.')
	}
}

fn error_message(msg string) {
	println(term.red('\nError: ') + msg)
	println(term.yellow("Run 'flist help' for usage information.\n"))
}

fn success_message(msg string) {
	println(term.green('\n' + msg + '\n'))
}

fn info_message(msg string) {
	println(term.cyan('\n' + msg + '\n'))
}

fn create_box(content []string, padding int) string {
	mut max_width := 0
	for line in content {
		clean_line := term.strip_ansi(line)
		if clean_line.len > max_width {
			max_width = clean_line.len
		}
	}
	max_width += padding * 2

	separator := '━'.repeat(max_width + 2) // +2 for left and right borders
	mut box_content := term.cyan('┏${separator}┓') + '\n'

	for line in content {
		clean_line := term.strip_ansi(line)
		padding_left := ' '.repeat(padding)
		padding_right := ' '.repeat(max_width - clean_line.len)
		box_content += term.cyan('┃') + padding_left + line + padding_right + term.cyan('┃') +
			'\n'
	}

	box_content += term.cyan('┗${separator}┛')
	return box_content
}

fn install() {
	info_message('Installing Flist CLI...')
	current_exe := os.executable()
	if os.exists(current_exe) {
		os.mkdir_all(os.dir(binary_location)) or {
			error_message('Failed to create directory for binary: ${err}')
			exit(1)
		}
		os.cp(current_exe, binary_location) or {
			error_message('Failed to copy binary to path: ${err}')
			exit(1)
		}
		os.chmod(binary_location, 0o755) or {
			error_message('Failed to change permissions to binary at path: ${err}')
			exit(1)
		}
		$if windows {
			add_path_windows()
		}
		success_message('Flist CLI has been installed to ' + binary_location)
		info_message("Run 'flist help' to see all commands.")
	} else {
		error_message('Cannot find the executable file')
		exit(1)
	}
}

fn uninstall() {
	info_message('Uninstalling Flist CLI...')

	if os.exists(binary_location) {
		// Remove the binary file
		os.rm(binary_location) or {
			error_message('Failed to remove the binary at path: ${err}')
			exit(1)
		}
		success_message('Flist CLI has been removed from ' + binary_location)
	} else {
		info_message('Flist CLI is not installed at ' + binary_location)
	}

	$if windows {
		remove_path_windows()
	}
}

fn login() {
	mut token_exists := os.exists(token_file)
	os.mkdir_all(config_dir) or {
		error_message('Failed to create config folder for token and Docker username files: ${err}')
		exit(1)
	}
	if !token_exists {
		tfhub_token := os.input('Please enter your TF Hub token: ')
		os.write_file(token_file, tfhub_token) or {
			error_message('Failed to write TF Hub token to file: ${err}')
			exit(1)
		}
		success_message('TF Hub token saved in ' + token_file)
	} else {
		info_message('Your TF Hub token is already saved.')
	}

	mut dockername_exists := os.exists(docker_username_file)
	mut docker_username := ''

	if !dockername_exists {
		docker_username = os.input('Please enter your Docker username: ')
		os.write_file(docker_username_file, docker_username) or {
			error_message('Failed to write Docker username to file: ${err}')
			exit(1)
		}
		success_message('Docker username saved in ' + docker_username_file)
	}

	docker_username = os.read_file(docker_username_file) or {
		error_message('Failed to read the Docker username from file: ${err}')
		exit(1)
	}

	info_message('Enter your Docker password')
	os.system('${docker_cmd} login -u ${docker_username}')

	success_message('TF Hub and Docker Hub login process completed.')
}

fn logout() {
	if os.exists(token_file) {
		os.rm(token_file) or {
			error_message('Failed to remove TF Hub token file at config directory: ${err}')
			exit(1)
		}
		success_message('Your TF Hub token has been removed')
	} else {
		info_message('Your TF Hub token was already not present.')
	}

	if os.exists(docker_username_file) {
		os.rm(docker_username_file) or {
			error_message('Failed to remove Docker username file in config folder: ${err}')
			exit(1)
		}
		success_message('Your Docker username has been removed from the config folder.')
	} else {
		info_message('Your Docker username was already not present in the config folder.')
	}

	exit_code := os.system('${docker_cmd} logout')
	if exit_code != 0 {
		error_message('Failed to log out from Docker Hub.')
	}

	success_message('You are now logged out of Docker Hub and your TF Hub token has been removed.')
}

fn push(tag string) {
	docker_user := os.read_file(docker_username_file) or {
		error_message("No Docker username found. Please run 'flist login' first.")
		exit(1)
	}

	info_message('Docker username: ${docker_user}')

	full_tag := '${docker_user}/${tag}'

	tfhub_token := os.read_file(token_file) or {
		error_message("No TF Hub token found. Please run 'flist login' first.")
		exit(1)
	}

	info_message('Starting Docker build')
	if os.system('${docker_cmd} buildx build -t ${full_tag} .') != 0 {
		error_message('Docker build failed')
		exit(1)
	}

	info_message('Finished local Docker build, now pushing to Docker Hub')
	if os.system('${docker_cmd} push ${full_tag}') != 0 {
		error_message('Docker push failed')
		exit(1)
	}

	info_message('Converting Docker image to Flist now...')

	url := 'https://hub.grid.tf/api/flist/me/docker'
	data := 'image=${full_tag}'

	mut config := http.FetchConfig{
		url:    url
		method: .post
		data:   data
		header: http.new_header(
			key:   .authorization
			value: 'bearer ${tfhub_token}'
		)
	}

	config.header.add_custom('Content-Type', 'application/x-www-form-urlencoded') or {
		error_message('Add custom failed: ${err}')
		exit(1)
	}

	response := http.fetch(config) or {
		error_message('HTTP POST request failed: ${err}')
		exit(1)
	}

	if response.status_code == 200 {
		hub_user := get_hub_username(tfhub_token) or {
			error_message('Failed to get TF Hub username')
			exit(1)
		}

		flist_name := full_tag.replace_each([':', '-', '/', '-']) + '.flist'
		flist_url := 'https://hub.grid.tf/${hub_user}/${flist_name}'

		success_content := [
			term.bold(term.green('Success!') +
				' Your Flist has been created and pushed to the TF Hub.'),
			'',
			term.bold('Flist Details:'),
			term.yellow('Name: ') + flist_name,
			term.yellow('User: ') + hub_user,
			term.yellow('URL:  ') + flist_url,
			'',
			'You can access your Flist using the URL above.',
			'To manage your Flists, use the following commands:',
			term.yellow('  flist ls    ') + ' - List all your Flists',
			term.yellow('  flist delete') + ' - Delete an Flist',
			term.yellow('  flist rename') + ' - Rename an Flist',
		]

		println(create_box(success_content, 2))
	} else {
		error_message('Request failed with status code: ${response.status_code}')
		println('Response body:')
		println(response.body)
		exit(1)
	}
}

fn delete(flist_name string) {
	tfhub_token := os.read_file(token_file) or {
		error_message("No TF Hub token found. Please run 'flist login' first.")
		exit(1)
	}

	info_message('Deleting Flist: ' + flist_name)
	url := 'https://hub.grid.tf/api/flist/me/' + flist_name
	config := http.FetchConfig{
		url:    url
		method: .delete
		header: http.new_header(key: .authorization, value: 'bearer ' + tfhub_token)
	}

	response := http.fetch(config) or {
		error_message('Failed to send delete request: ' + err.msg())
		exit(1)
	}

	if response.status_code == 200 {
		success_message('Deletion request sent successfully.')
	} else {
		error_message('Deletion request failed with status code: ' + response.status_code.str())
	}
}

fn rename(flist_name string, new_flist_name string) {
	tfhub_token := os.read_file(token_file) or {
		error_message("No TF Hub token found. Please run 'flist login' first.")
		exit(1)
	}

	info_message('Renaming Flist: ' + flist_name + ' to ' + new_flist_name)
	url := 'https://hub.grid.tf/api/flist/me/' + flist_name + '/rename/' + new_flist_name
	config := http.FetchConfig{
		url:    url
		method: .get
		header: http.new_header(key: .authorization, value: 'bearer ' + tfhub_token)
	}

	response := http.fetch(config) or {
		error_message('Failed to send rename request: ' + err.msg())
		exit(1)
	}

	if response.status_code == 200 {
		success_message('Rename request sent successfully.')
	} else {
		error_message('Rename request failed with status code: ' + response.status_code.str())
	}
}

fn get_hub_username(tfhub_token string) ?string {
	url := 'https://hub.grid.tf/api/flist/me'

	config := http.FetchConfig{
		url:    url
		method: .get
		header: http.new_header(
			key:   .authorization
			value: 'bearer ${tfhub_token}'
		)
	}

	response := http.fetch(config) or {
		error_message('Failed to fetch hub username: ${err}')
		return none
	}

	if response.status_code != 200 {
		error_message('Failed to fetch hub username. Status code: ${response.status_code}')
		return none
	}

	parsed_response := json.decode(Response, response.body) or {
		error_message('Failed to parse JSON response: ${err}')
		return none
	}

	if parsed_response.payload.username != '' {
		return parsed_response.payload.username
	}

	error_message('Username not found in response')
	return none
}

fn ls(show_url bool) {
	tfhub_token := os.read_file(token_file) or {
		error_message("No TF Hub token found. Please run 'flist login' first.")
		exit(1)
	}

	hub_user := get_hub_username(tfhub_token) or {
		error_message('Failed to get hub username')
		exit(1)
	}

	url := 'https://hub.grid.tf/api/flist/${hub_user}'

	config := http.FetchConfig{
		url:    url
		method: .get
		header: http.new_header(
			key:   .authorization
			value: 'bearer ${tfhub_token}'
		)
	}

	response := http.fetch(config) or {
		error_message('Failed to fetch data: ${err}')
		exit(1)
	}

	if response.status_code != 200 {
		error_message('Failed to fetch data. Status code: ${response.status_code}')
		exit(1)
	}

	data := json.decode([]FlistItem, response.body) or {
		error_message('Failed to parse JSON: ${err}')
		exit(1)
	}

	mut content := [term.bold('Flists for user ' + term.green(hub_user) + ':')]
	for item in data {
		if show_url {
			content << term.yellow('> ') + 'https://hub.grid.tf/' + hub_user + '/' + item.name
		} else {
			content << term.yellow('> ') + item.name
		}
	}

	println(create_box(content, 2))
}

fn help() {
	welcome_msg := term.bold(term.green('Welcome to the Flist CLI!'))
	println(create_box([welcome_msg], 2))

	println('This tool turns Dockerfiles and Docker images directly into Flists on the TF Flist Hub, passing by the Docker Hub.\n')
	println(term.cyan(info_msg))
	println(term.bold('Available commands:'))
	println(term.cyan('  install  ') + ' - Install the Flist CLI')
	println(term.cyan('  uninstall') + ' - Uninstall the Flist CLI')
	println(term.cyan('  login    ') + ' - Log in to Docker Hub and save the Flist Hub token')
	println(term.cyan('  logout   ') + ' - Log out of Docker Hub and remove the Flist Hub token')
	println(term.cyan('  push     ') +
		' - Build and push a Docker image to Docker Hub, then convert and push it as an Flist to Flist Hub')
	println(term.cyan('  delete   ') + ' - Delete an Flist from Flist Hub')
	println(term.cyan('  rename   ') + ' - Rename an Flist in Flist Hub')
	println(term.cyan('  ls       ') + ' - List all Flists of the current user')
	println(term.cyan('  ls url   ') + ' - List all Flists of the current user with full URLs')
	println(term.cyan('  help     ') + ' - Display this help message\n')
	println(term.bold('Usage:'))
	$if linux {
		println(term.yellow('  sudo ./flist install') + term.cyan(flist_repo_folder))
		println(term.yellow('  sudo flist uninstall'))
	} $else $if macos {
		println(term.yellow('  sudo ./flist install') + term.cyan(flist_repo_folder))
		println(term.yellow('  flist uninstall'))
	} $else $if windows {
		println(term.yellow('  ./flist.exe install') + term.cyan(flist_repo_folder))
		println(term.yellow('  ./flist.exe uninstall') + term.cyan(flist_repo_folder))
	}
	println(term.yellow('  flist login'))
	println(term.yellow('  flist logout'))
	println(term.yellow('  flist push <image>:<tag>'))
	println(term.yellow('  flist delete <flist_name>'))
	println(term.yellow('  flist rename <flist_name> <new_flist_name>'))
	println(term.yellow('  flist ls'))
	println(term.yellow('  flist ls url'))
	println(term.yellow('  flist help\n'))
}

fn main() {
	if os.args.len == 1 {
		help()
		return
	}

	match os.args[1] {
		'install' {
			install()
		}
		'uninstall' {
			uninstall()
		}
		'push' {
			if os.args.len == 3 {
				push(os.args[2])
			} else {
				error_message("Incorrect number of arguments for 'push'.")
				exit(1)
			}
		}
		'login' {
			login()
		}
		'logout' {
			logout()
		}
		'delete' {
			if os.args.len == 3 {
				delete(os.args[2])
			} else {
				error_message("Incorrect number of arguments for 'delete'.")
				exit(1)
			}
		}
		'rename' {
			if os.args.len == 4 {
				rename(os.args[2], os.args[3])
			} else {
				error_message("Incorrect number of arguments for 'rename'.")
				exit(1)
			}
		}
		'ls' {
			if os.args.len == 2 {
				ls(false)
			} else if os.args.len == 3 && os.args[2] == 'url' {
				ls(true)
			} else {
				error_message("Incorrect usage of 'ls'. Use 'ls' or 'ls url'.")
				exit(1)
			}
		}
		'help' {
			help()
		}
		else {
			error_message('Unknown command: ' + os.args[1])
			exit(1)
		}
	}
}
