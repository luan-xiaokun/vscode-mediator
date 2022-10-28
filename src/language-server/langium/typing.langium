import './mediator'

// Variable Typing
VariableTypingRule returns VariableTyping:
    var=VariableNameRule ':' type=TypeRule;

MultipleVariableTyping returns MultipleVariableTyping:
    vars+=VariableNameRule (',' vars+=VariableNameRule)* ':' type=TypeRule;

VariableNameRule returns VariableName:
    name=FeatureID;

// Port Typing
PortTypingRule returns PortTyping:
    name=FeatureID ':' type=PortType;

// Component Typing
ComponentTypingRule returns ComponentTyping:
    components+=ComponentName (',' names+=ComponentName)* ':' ComponentInstantiation;

ComponentName returns ComponentName:
    name=FeatureID;

ComponentInstantiation returns ComponentInstantiation:
    component=[NamedAutomaton:FeatureID] ('<' templates+=AdditiveExpression (',' templates+=AdditiveExpression)* '>')?;

// Template Typing
SystemTemplateTyping returns TemplateTyping:
    name=FeatureID ':' type=(TypeRule | ParameterType);

NonSystemTemplateTyping returns TemplateTyping:
    name=FeatureID ':' type=(TypeRule | NonInterfaceParameterType);

fragment SystemTemplateList:
    templates+=SystemTemplateTyping (',' templates+=SystemTemplateTyping)*;

fragment NonSystemTemplateList:
    templates+=NonSystemTemplateTyping (',' templates+=NonSystemTemplateTyping)*;
