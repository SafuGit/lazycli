#!/bin/bash

VERSION="safu_docker-1.0.1"

show_help() {
  cat << EOF
LazyCLI – Automate your dev flow like a lazy pro 💤

Usage:
  lazy [command] [subcommand]

Examples:
  lazy github init
      Initialize a new Git repository in the current directory.

  lazy github clone <repo-url>
      Clone a GitHub repository and auto-detect the tech stack for setup.

  lazy github push "<commit-message>"
      Stage all changes, commit with the given message, and push to the current branch.

  lazy github pr <base-branch> "<commit-message>"
      Pull latest changes from the base branch, install dependencies, commit local changes,
      push to current branch, and create a GitHub pull request.

  lazy github pull <base-branch> "<pr-title>"
      Create a simple pull request from current branch to the specified base branch.

  lazy next-js create
      Scaffold a new Next.js application with recommended defaults and optional packages.

  lazy --version | -v
      Show current LazyCLI version.

  lazy --help | help
      Show this help message.

Available Commands:

  github        Manage GitHub repositories:
                - init       Initialize a new Git repo
                - clone      Clone a repo and optionally setup project
                - push       Commit and push changes with message
                - pull       Create a simple pull request from current branch
                - pr         Pull latest, build, commit, push, and create pull request

  next-js       Next.js project scaffolding:
                - create     Create Next.js app with TypeScript, Tailwind, ESLint defaults

For more details on each command, run:
  lazy [command] --help

EOF
}

echo "LazyCLI Version: $VERSION"
echo "Working..."

# *HELPER FUNCTIONS TO CREATE DOCKERFILES.
create_node_dockerfile() {
  read -p "npm start command (default: npm start): " npm_start_command
  if [[ -z "$npm_start_command" ]]; then
    echo "Defaulting to: npm start"
    npm_start_command="start"
  fi
  cat << EOF > Dockerfile
# Node.js Dockerfile (AUTO-CREATED)
FROM node:20-alpine

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

CMD ["npm", "${npm_start_command}"]
EOF
  if [[ -f Dockerfile ]]; then
    echo "Dockerfile created successfully."
  else
    echo "Failed to create Dockerfile."
  fi
}

create_react_vite_dockerfile() {
  read -p "app port (default: 5173): " app_port
  if [[ -z "$app_port" ]]; then
    echo "Defaulting to: 5173"
    app_port=5173
  fi
  cat << EOF > Dockerfile
# React.js Vite Dockerfile (AUTO-CREATED)
FROM node:20-alpine AS BUILDER

# STEP 1: BUILD
WORKDIR /app
COPY package*.json ./
RUN npm install

COPY . .
RUN npm run build

# STEP 2: SERVE WITH ALPINE
FROM nginx:alpine

# Copy the built app to Nginx's default public folder
COPY --from=builder /app/dist /usr/share/nginx/html

# Expose the port
EXPOSE $app_port

# Start Nginx when container runs
CMD ["nginx", "-g", "daemon off;"]
EOF
}

docker_init() {
  echo "Initializing Docker configuration..."

  cat << EOF
Select a Dockerfile template to create:
  [1] Node.js Dockerfile
  [2] React.js-Vite Dockerfile
  [3] SpringBoot Dockerfile
  [4] Python Dockerfile
  [5] Python Flask Dockerfile
EOF

  read -p "Enter your choice (1-5): " choice
  case "$choice" in 
    1|2|3|4|5)
      ;;
    *)
      echo "Invalid choice. Exiting..."
      exit 1
      ;;
  esac

  if [[ -f Dockerfile ]]; then
    read -p "Dockerfile already exists. Overwrite? (y/n): " confirm
    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
      echo "Aborted."
      return 1
    fi
  fi

  case "$choice" in
    1) create_node_dockerfile ;;
    2) create_react_vite_dockerfile ;;
    3) create_springboot_dockerfile ;;
    4) create_python_dockerfile ;;
    5) create_python_flask_dockerfile ;;
  esac
}

# *Main CLI Router
case "$1" in
  --help | help )
    show_help
    ;;
  --version | -v )
    echo "LazyCLI v$VERSION"
    ;;
  docker )
    case "$2" in
      init)
        docker_init
        ;;
      *)
        echo "❌ Unknown docker subcommand: $2"
        show_help
        exit 1
        ;;
    esac
    ;;
  *)
    echo "❌ Unknown command: $1"
    show_help
    exit 1
    ;;
esac