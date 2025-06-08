# 鸿蒙提示工具类详解

## 代码功能概述
这段代码定义了一个名为`PromptUtil`的工具类，用于在鸿蒙应用中显示Toast提示消息，为应用提供了统一的消息提示机制。

## 详细代码分析

### 导入部分
```typescript
import CommonConstants from '../constants/CommonConstants';
import { promptAction } from '@kit.ArkUI';
```
- 导入了项目中的常量定义文件`CommonConstants`
- 从鸿蒙的ArkUI套件中导入了`promptAction`模块，这是系统提供的消息提示API

### 类定义
```typescript
class PromptUtil {
  promptMessage(message: string | Resource, time: number, bottom: string | number = CommonConstants.PROMPT_BOTTOM) {
    promptAction.showToast({
      message: message,
      duration: time,
      bottom: bottom
    })
  }
}
```

#### 方法解析：`promptMessage`
- **参数说明**：
  - `message`：提示的消息内容，可以是字符串或者资源引用（如$r('app.string.message')）
  - `time`：提示显示的持续时间（毫秒）
  - `bottom`：提示框距离屏幕底部的距离，默认使用CommonConstants中的PROMPT_BOTTOM常量
  
- **方法功能**：
  调用系统的`promptAction.showToast`方法，显示一个从底部弹出的提示框

- **参数类型**：
  - `string | Resource`表示参数可以是字符串或资源类型
  - 参数`bottom`有默认值，表示可选参数

### 导出实例
```typescript
export default new PromptUtil();
```
- 创建了`PromptUtil`类的实例并导出
- 使用`default`关键字表示这是模块的默认导出
- 这样其他文件可以直接导入并使用这个实例，不需要再创建新实例

## 使用示例
```typescript
import promptUtil from '../utils/PromptUtil';

// 在代码中使用
function onButtonClick() {
  // 显示提示，持续2000毫秒
  promptUtil.promptMessage('操作成功！', 2000);
  
  // 使用资源字符串并自定义位置
  promptUtil.promptMessage($r('app.string.success_msg'), 3000, '30%');
}
```

这个工具类封装了鸿蒙系统的Toast提示功能，使应用中的提示消息显示更加统一和便捷，是用户界面交互中常用的反馈方式。