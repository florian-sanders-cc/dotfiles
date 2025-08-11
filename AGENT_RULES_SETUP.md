# Agent Rules Setup - Claude CLI-like Behavior for Zed

This document explains the comprehensive agent rules system that has been implemented to provide Claude CLI-like behavior in Zed editor, with structured planning, research capabilities, and explicit handling of limitations.

## What Was Created

### 1. Project-Level Rules (`.rules`)
**Location**: `nixos-config/.rules`
**Purpose**: Default behavior applied to ALL agent interactions in this project

**Key Features**:
- Always starts with a markdown todo list plan
- Uses Context7 and web search when uncertain
- Explicitly states when information cannot be found
- Clearly explains when something is impossible/impractical
- Follows Claude CLI structured approach with iteration support

### 2. Specialized Profiles for Rules Library
**Location**: `nixos-config/dotfiles/zed/rules/`

#### Ask Profile (`ask-profile.md`)
- **Purpose**: Research and knowledge-focused interactions
- **Best For**: Technical questions, documentation lookup, concept explanations
- **Behavior**: Thorough research with source attribution, explicit uncertainty handling

#### Coding Profile (`coding-profile.md`)  
- **Purpose**: Development and implementation tasks
- **Best For**: Writing code, refactoring, architecture decisions, code reviews
- **Behavior**: Production-ready code, follows existing patterns, comprehensive error handling

#### Debug Profile (`debug-profile.md`)
- **Purpose**: Troubleshooting and problem resolution
- **Best For**: Diagnosing errors, system issues, performance problems
- **Behavior**: Systematic investigation, root cause analysis, step-by-step debugging

### 3. Documentation and Guides
- **Profile Usage Guide** (`README.md`): Complete instructions on when and how to use each profile
- **NixOS Integration**: Rules are properly tracked and deployed via your NixOS configuration

## How It Works

### Automatic Application
The main `.rules` file is automatically applied to all agent conversations in this project, ensuring consistent Claude CLI-like behavior without any manual intervention.

### Manual Profile Selection
For specialized needs, you can:
1. Use the Rules Library in Zed to select specific profiles
2. Use `@rule profile-name` in conversations
3. Copy/paste profile content for custom scenarios

### Research Integration
All profiles are configured to:
- Use Context7 for documentation and official sources
- Use web search for current information and community insights
- Explicitly state when information cannot be found
- Acknowledge technical impossibilities with explanations

## Core Behaviors

### Planning Phase
Every agent response starts with:
```markdown
## Plan
- [ ] Step 1: Brief description
- [ ] Step 2: Brief description
- [ ] Step 3: Brief description
```

### Research Strategy
- **Context7 First**: Official documentation and specifications
- **Web Search**: Current trends, issues, community solutions
- **Explicit Uncertainty**: "I could not find reliable information about X"
- **Clear Impossibilities**: "This appears to be impossible/impractical because..."

### Iterative Approach
- Plans can be reviewed and modified before implementation
- Progress updates during complex tasks
- Open to feedback and plan adjustments

## Profile Selection Guide

| Task Type | Recommended Profile | Why |
|-----------|-------------------|-----|
| "How do I...?" questions | Ask Profile | Research and explanation focus |
| "Help me implement..." | Coding Profile | Production code implementation |
| "This isn't working..." | Debug Profile | Systematic troubleshooting |
| General development | Project Rules | Balanced planning approach |

## NixOS Integration

### Configuration Management
The rules are integrated into your NixOS configuration at:
- `modules/packages/zed.nix` - Links rules directory to Zed config
- Automatically deployed when you rebuild your system
- Version controlled with the rest of your configuration

### Context Awareness
All profiles understand your specific setup:
- NixOS configuration patterns
- Zed + Context7 integration
- Development tool configurations
- System-specific conventions

## Usage Examples

### Using Default Behavior
Just start a conversation in Zed's Agent Panel - the main rules automatically apply:
```
"Help me configure a new language server in my NixOS setup"
```

### Using Specific Profiles
```
@rule ask-profile

What are the latest best practices for NixOS flake configurations?
```

### Switching Profiles Mid-Conversation
```
@rule debug-profile

Now help me troubleshoot why my language server isn't starting
```

## Benefits

### Consistency
- Every interaction follows the same structured approach
- Predictable planning and research phases
- Consistent quality and thoroughness

### Transparency  
- Clear about what can and cannot be determined
- Shows research process and sources
- Honest about limitations and impossibilities

### Efficiency
- Right profile for the right task
- Structured planning prevents wasted effort
- Research integration provides accurate, current information

### Integration
- Works seamlessly with your existing NixOS workflow
- Leverages Context7 and web search capabilities
- Maintains consistency with your development environment

## Customization

The system is designed to be easily customizable:
- Modify existing profiles for your specific needs
- Create new profiles for specialized use cases
- Adjust the main `.rules` file for different default behavior
- All changes are tracked in your NixOS configuration

This setup transforms Zed's AI assistant into a structured, research-capable partner that behaves consistently with Claude CLI while being optimized for your specific development environment and workflow.