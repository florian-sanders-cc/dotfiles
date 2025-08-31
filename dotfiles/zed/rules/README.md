# Zed Agent Rules and Profiles Guide

This directory contains specialized agent rules and profiles for different types of interactions with AI assistants in Zed. Each profile is designed to optimize the assistant's behavior for specific use cases.

## Available Profiles

### 1. Project-Level Rules (`.rules`)
- **Location**: `nixos-config/.rules`
- **Purpose**: Default behavior for all agent interactions in this project
- **Behavior**: Claude CLI-like behavior with structured planning and research
- **Auto-applied**: Yes (to all conversations in this project)

### 2. Ask Profile (`ask-profile.md`)
- **Purpose**: Research and knowledge-focused interactions
- **Best for**: 
  - Answering technical questions
  - Researching technologies and best practices
  - Understanding concepts and documentation
  - Getting current information about tools/libraries
- **Key features**: Thorough research using Context7 and web search, source attribution, explicit uncertainty handling

### 3. Coding Profile (`coding-profile.md`)
- **Purpose**: Development and implementation tasks
- **Best for**:
  - Writing new code or features
  - Refactoring existing code
  - Code reviews and improvements
  - Architecture and design decisions
- **Key features**: Production-ready code, follows existing patterns, comprehensive error handling

### 4. Debug Profile (`debug-profile.md`)
- **Purpose**: Troubleshooting and problem resolution
- **Best for**:
  - Diagnosing errors and issues
  - System troubleshooting
  - Performance problems
  - Configuration issues
- **Key features**: Systematic investigation, root cause analysis, step-by-step debugging

## How to Use Profiles

### Method 1: Rules Library (Recommended)
1. Open the Agent Panel in Zed
2. Click the menu button (`...`) in the top right
3. Select "Rules..." to open the Rules Library
4. Import or create rules based on the profiles above
5. Select the appropriate rule for your conversation type

### Method 2: Manual Reference
Use the `@rule` command in your conversation to reference specific profiles:
```
@rule ask-profile

How do I configure Zed to work with Context7?
```

### Method 3: Copy and Paste
Copy the content of the relevant profile and paste it at the beginning of your conversation to set the context.

## Profile Selection Guide

| Task Type | Recommended Profile | Why |
|-----------|-------------------|-----|
| "How do I...?" questions | Ask Profile | Optimized for research and explanation |
| "Help me implement..." | Coding Profile | Focused on writing production code |
| "This isn't working..." | Debug Profile | Systematic troubleshooting approach |
| General coding help | Project Rules | Balanced approach with planning |
| Architecture decisions | Coding Profile | Technical implementation focus |
| Understanding errors | Debug Profile | Root cause analysis |
| Learning new technology | Ask Profile | Research and knowledge gathering |

## Common Patterns

### All Profiles Include:
- **Planning Phase**: Every response starts with a markdown todo list plan
- **Research First**: Use Context7 and web search when uncertain
- **Explicit Limitations**: Clear statements about what cannot be determined
- **Iterative Approach**: Plans can be modified based on feedback

### Profile-Specific Behaviors:
- **Ask**: Focuses on gathering and synthesizing information
- **Coding**: Emphasizes code quality and implementation details  
- **Debug**: Uses systematic investigation and root cause analysis

## Tips for Best Results

1. **Be Specific**: Choose the profile that best matches your primary need
2. **Provide Context**: Include relevant details about your environment and setup
3. **Iterate on Plans**: Review and refine the initial plan before proceeding
4. **Use Multiple Profiles**: Switch profiles as your conversation evolves
5. **Leverage Research**: Take advantage of Context7 and web search capabilities

## Customization

Feel free to:
- Modify these profiles for your specific needs
- Create new profiles for specialized use cases
- Combine elements from different profiles
- Add project-specific instructions

## NixOS Integration

All profiles are aware of:
- Your NixOS configuration structure
- Existing tool configurations (Zed, Neovim, etc.)
- Development environment setup
- System-specific patterns and conventions

This ensures consistent behavior across all interactions while maintaining your specific setup and preferences.