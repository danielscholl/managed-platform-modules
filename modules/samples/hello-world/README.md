# Hello World

## Description

{{ Add detailed description for the module. }}

## Parameters

| Name   | Type     | Required | Description                       |
| :----- | :------: | :------: | :-------------------------------- |
| `name` | `string` | Yes      | The name of someone to say hi to. |

## Outputs

| Name     | Type   | Description        |
| :------- | :----: | :----------------- |
| greeting | string | The hello message. |

## Examples

```bicep
module helloWorld 'br/managedplatform.azurecr.io:samples/hello-world:1.0.0' = {
  name: 'helloWorld'
  params: {
    name: 'Bicep developers'
  }
}

output greeting string = helloWorld.outputs.greeting
```
