import React from 'react';
import { Form, Input, Checkbox } from 'antd';
import { UserOutlined, LockOutlined } from '@ant-design/icons';

import useLanguage from '@/locale/useLanguage';

export default function LoginForm() {
  const translate = useLanguage();
  return (
    <div>
      <Form.Item
        label={translate('email')}
        name="email"
        rules={[
          {
            required: true,
            message: translate('Please input your email!'),
          },
          {
            type: 'email',
            message: translate('Please enter a valid email address!'),
          },
        ]}
      >
        <Input
          prefix={<UserOutlined className="site-form-item-icon" />}
          placeholder={'admin@demo.com'}
          type="email"
          size="large"
        />
      </Form.Item>
      <Form.Item
        label={translate('password')}
        name="password"
        rules={[
          {
            required: true,
            message: translate('Please input your password!'),
          },
          {
            min: 8,
            message: translate('Password must be at least 8 characters!'),
          },
          {
            pattern: /[A-Z]/,
            message: translate('Password must contain at least one uppercase letter!'),
          },
          {
            pattern: /[a-z]/,
            message: translate('Password must contain at least one lowercase letter!'),
          },
          {
            pattern: /[0-9]/,
            message: translate('Password must contain at least one number!'),
          },
          {
            pattern: /[!@#$%^&*(),.?":{}|<>]/,
            message: translate('Password must contain at least one special character!'),
          },
        ]}
      >
        <Input.Password
          prefix={<LockOutlined className="site-form-item-icon" />}
          placeholder={'admin123'}
          size="large"
        />
      </Form.Item>

      <Form.Item>
        <Form.Item name="remember" valuePropName="checked" noStyle>
          <Checkbox>{translate('Remember me')}</Checkbox>
        </Form.Item>
        <a className="login-form-forgot" href="/forgetpassword" style={{ marginLeft: '0px' }}>
          {translate('Forgot password')}
        </a>
      </Form.Item>
    </div>
  );
}
