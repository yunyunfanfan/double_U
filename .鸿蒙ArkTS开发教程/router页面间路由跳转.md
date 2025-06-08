# 鸿蒙系统中实现页面跳转的方法

在鸿蒙开发中，页面跳转主要通过`router`模块来实现。下面详细介绍几种常用的页面跳转方法：

## 1. 基本页面跳转

首先需要导入router模块：

```typescript
import router from '@ohos.router';
```

### 1.1 普通跳转 (pushUrl)

```typescript
// 跳转到目标页面
router.pushUrl({
  url: 'pages/SecondPage'  // 目标页面路径
})
.then(() => {
  console.info('页面跳转成功');
})
.catch(err => {
  console.error(`跳转失败，错误：${err.message}`);
});
```

### 1.2 带参数跳转

```typescript
// 带参数跳转到目标页面
router.pushUrl({
  url: 'pages/DetailPage',
  params: {
    userId: '1001',
    userName: '李逸飞',
    userAge: 25
  }
})
```

## 2. 接收参数

在目标页面接收传递的参数：

```typescript
@Entry
@Component
struct DetailPage {
  @State userId: string = '';
  @State userName: string = '';
  @State userAge: number = 0;
  
  aboutToAppear() {
    // 获取路由参数
    const params = router.getParams();
    if (params) {
      this.userId = params['userId'] ?? '';
      this.userName = params['userName'] ?? '';
      this.userAge = params['userAge'] ?? 0;
    }
  }
  
  build() {
    // 页面UI构建...
  }
}
```

## 3. 页面返回

### 3.1 返回上一页

```typescript
// 返回上一页
router.back()
```

### 3.2 带结果返回

```typescript
// 返回上一页并传递结果
router.back({
  url: 'pages/Index',  // 可选，指定返回的页面
  params: {
    result: '操作成功',
    code: 200
  }
});
```

## 4. 高级跳转方式

### 4.1 替换当前页面 (replaceUrl)

```typescript
// 替换当前页面，无法返回
router.replaceUrl({
  url: 'pages/NewPage'
});
```

### 4.2 清空历史并跳转 (clear)

```typescript
// 清空历史栈并跳转
router.clear();
router.pushUrl({
  url: 'pages/HomePage'
});
```

## 5. 页面跳转事件监听

```typescript
// 监听路由事件
onPageShow() {
  // 页面显示时触发
  console.info('页面显示');
}

onBackPress() {
  // 返回键按下时触发
  console.info('用户点击了返回键');
  return false; // 返回true表示自行处理返回逻辑，false表示使用默认行为
}
```

通过以上方法，您可以在鸿蒙应用中实现灵活的页面导航和参数传递。记得在使用前先在`main_pages.json`中注册所有页面路径。