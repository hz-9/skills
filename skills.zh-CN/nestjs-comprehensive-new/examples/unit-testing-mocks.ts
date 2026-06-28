import { Test, TestingModule } from '@nestjs/testing';
import { UsersService } from './users.service';
import { UsersRepository } from './users.repository';
import { NotFoundException } from '@nestjs/common';

/**
 * 单元测试 - Mock 示例
 *
 * 演示：
 * - 使用模拟 Repository 进行 Service 测试
 * - 成功和失败场景
 * - 正确的 async/await 处理
 */
describe('UsersService', () => {
  let service: UsersService;
  let repo: jest.Mocked<UsersRepository>;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        UsersService,
        {
          provide: UsersRepository,
          useValue: {
            findById: jest.fn(),
            findAll: jest.fn(),
            findByEmail: jest.fn(),
            create: jest.fn(),
            update: jest.fn(),
            delete: jest.fn(),
          },
        },
      ],
    }).compile();

    service = module.get<UsersService>(UsersService);
    repo = module.get(UsersRepository);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('findById', () => {
    it('should return user when found', async () => {
      // 准备
      const mockUser = {
        id: 1,
        name: 'John Doe',
        email: 'john@example.com',
        createdAt: new Date(),
      };
      repo.findById.mockResolvedValue(mockUser);

      // 执行
      const result = await service.findById(1);

      // 断言
      expect(result).toEqual(mockUser);
      expect(repo.findById).toHaveBeenCalledWith(1);
      expect(repo.findById).toHaveBeenCalledTimes(1);
    });

    it('should throw NotFoundException when user not found', async () => {
      // 准备
      repo.findById.mockResolvedValue(undefined);

      // 执行和断言
      await expect(service.findById(999)).rejects.toThrow(NotFoundException);
      expect(repo.findById).toHaveBeenCalledWith(999);
    });
  });

  describe('findAll', () => {
    it('should return array of users', async () => {
      // 准备
      const mockUsers = [
        { id: 1, name: 'John', email: 'john@example.com', createdAt: new Date() },
        { id: 2, name: 'Jane', email: 'jane@example.com', createdAt: new Date() },
      ];
      repo.findAll.mockResolvedValue(mockUsers);

      // 执行
      const result = await service.findAll();

      // 断言
      expect(result).toEqual(mockUsers);
      expect(repo.findAll).toHaveBeenCalledTimes(1);
    });

    it('should return empty array when no users', async () => {
      // 准备
      repo.findAll.mockResolvedValue([]);

      // 执行
      const result = await service.findAll();

      // 断言
      expect(result).toEqual([]);
    });
  });

  describe('create', () => {
    it('should create and return user', async () => {
      // 准备
      const dto = { name: 'John Doe', email: 'john@example.com' };
      const mockUser = {
        id: 1,
        ...dto,
        createdAt: new Date(),
      };
      repo.create.mockResolvedValue(mockUser);

      // 执行
      const result = await service.create(dto);

      // 断言
      expect(result).toEqual(mockUser);
      expect(repo.create).toHaveBeenCalledWith(dto);
    });
  });

  describe('delete', () => {
    it('should delete user and return deleted user', async () => {
      // 准备
      const mockUser = {
        id: 1,
        name: 'John',
        email: 'john@example.com',
        createdAt: new Date(),
      };
      repo.delete.mockResolvedValue(mockUser);

      // 执行
      const result = await service.delete(1);

      // 断言
      expect(result).toEqual(mockUser);
      expect(repo.delete).toHaveBeenCalledWith(1);
    });
  });
});
